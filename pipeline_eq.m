% Resolución de sistema de ecuaciones upper-triangular con Pipeline

clear all;

N = 3; % Tamaño del Sistema

p = gcp('nocreate'); % If no pool, do not create new one.

if isempty(p)
    c = parcluster;
    c.NumWorkers = N;
    c.parpool(N); % MPI_INIT
end


% Sistema de ecuaciones
A = triu(rand(N));
b = rand(N, 1);


spmd(N)
    pid = spmdIndex; % MPI_Comm_rank 
    NP = spmdSize; % MPI_Comm_size
    switch pid
        case 1
            % Sistema a resolver
            display(A);
            display(b);
            % Encontramos X_1
            x_local = b(pid) / A(pid, pid);
            display(x_local);
            % Enviamos X_1 al siguiente procesador
            spmdSend(x_local, pid + 1);
        case NP
            sum_local = 0;
            % Vector con los resultados X_1 ... X_NP-1
            result = zeros(pid, 1);
            for j = 1:pid-1
                % Recibimos los datos del procesador anterior
                result(j) = spmdReceive(pid - 1);
                % Realizamos la suma local
                sum_local = sum_local + A(pid, j) * result(j);
            end
            % Calculamos X_NP y lo guardamos en el vector resultado
            result(pid) = (b(pid) - sum_local) / A(pid, pid);
            % Vector resultado
            display(result);
        otherwise
            sum_local = 0;
            % Vector con los resultados X_1 ... X_pid-1
            x_prev = zeros(pid - 1, 1);
            for j = 1:pid-1
                % Recibimos los datos del procesador anterior
                x_prev(j) = spmdReceive(pid - 1);
                % Enviamos los datos al procesador siguiente
                spmdSend(x_prev(j), pid + 1);
                % Realizamos la suma local
                sum_local = sum_local + A(pid, j) * x_prev(j);
            end
            % Calculamos X_pid
            x_local = (b(pid) - sum_local) / A(pid, pid);
            display(x_local);
            % Enviamos X_pid al procesador siguiente
            spmdSend(x_local, pid + 1);
    end
end
