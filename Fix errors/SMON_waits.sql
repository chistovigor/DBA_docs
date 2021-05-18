Doc ID:  Note:464246.1

Wait for stopper event to be increased

alter system set fast_start_parallel_rollback = false;

-- after that change parameter back

alter system set fast_start_parallel_rollback = LOW;
