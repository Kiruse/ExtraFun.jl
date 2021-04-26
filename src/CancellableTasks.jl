######################################################################
# Cancellable tasks & tasks with timeouts.
# TODO: What about @sync & @async compatibility?
# -----
# Licensed under MIT License
module CancellableTasks
import ..ExtraFun
import ..ExtraFun: @await, CancellationError, TimeoutError

struct CancellableTask
    wrapped::Task
end
export with_cancel
function with_cancel(cb, schedule_immediately::Bool = true)
    task = CancellableTask(@task cb())
    if schedule_immediately
        schedule(task)
    end
end

"""`cancel(cancellable_task, reason = nothing)`
Cancel a blocking/yielding task with a `CancellationError(reason)`. The task may intercept this error in a try ... catch
block if necessary."""
function ExtraFun.cancel(task::CancellableTask, reason = nothing)
    if task.wrapped._state == 0
        schedule(task.wrapped, CancellationError(reason), error=true)
    end
    return task
end

Base.schedule(task::CancellableTask) = (schedule(task.wrapped); task)
Base.schedule(task::CancellableTask, val; error::Bool = false) = (schedule(task.wrapped, val, error=error); task)
Base.wait(task::CancellableTask) = wait(task.wrapped)
Base.fetch(task::CancellableTask) = fetch(task.wrapped)


struct TimeoutTask
    task_cb::Task
    task_timeout::Task
    _scheduled_once::Ref{Bool}
end
export with_timeout
function with_timeout(cb, timeout::Real; schedule_immediately::Bool = true)
    if timeout <= 0
        return with_cancel(cb, schedule_immediately)
    end
    
    task_cb = @task begin
        result = cb()
        schedule(task_timeout, CancellationError(), error=true)
        return result
    end
    task_timeout = @task begin
        sleep(timeout)
        schedule(task_cb, TimeoutError(), error=true)
    end
    
    wrapper = TimeoutTask(task_cb, task_timeout, Ref{Bool}(false))
    if schedule_immediately
        schedule(wrapper)
        wrapper._scheduled_once[] = true
    end
    wrapper
end

function ExtraFun.cancel(task::TimeoutTask, reason = nothing)
    if task.task_cb._state == 0
        err = CancellationError(reason)
        schedule(task.task_cb,      err, error=true)
        schedule(task.task_timeout, err, error=true)
    end
    return task
end

function Base.schedule(task::TimeoutTask)
    schedule(task.task_cb)
    schedule(task.task_timeout)
    return task
end
function Base.schedule(task::TimeoutTask, val; error::Bool = false)
    schedule(task.task_cb, val, error=true)
    if error
        schedule(task.task_timeout, val, error=true)
    else
        schedule(task.task_timeout)
    end
    return task
end
function Base.wait(task::TimeoutTask)
    if !task._scheduled_once[]
        schedule(task.task_timeout)
        _scheduled_once[] = true
    end
    wait(task.task_cb)
    task
end
function Base.fetch(task::TimeoutTask)
    wait(task)
    return fetch(task.task_cb)
end

end # module CancellableTasks
