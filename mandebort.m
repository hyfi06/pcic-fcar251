clear all;
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool(4); % MPI_INIT
end

%Protocolos
TAG_DATOS = 1;
TAG_RESULTADOS = 2;
TAG_CONTRON = 3;


spmd
    pid = spmdIndex; % MPI_RANK
    NP = spmdSize; % MPI_SIZE
    NT = NP - 1;
    if pid ==0 % Farmer
        MAX_tareas = 100;
        tareas = 0;
        ocupados = 0;

        % Primera etapa
        for p = 1:NT
            spmdSend(dato, p+1, TAG_DATOS);
        end
    else % Worker  

    end
    fprintf("Fin, pid=%d",pid)
end