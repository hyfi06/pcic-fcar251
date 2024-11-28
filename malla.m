% Malla carteciana

% COL,ROW

% 1,1 2,1 3,1
% 1,2 2,2 3,2
% 1,3 2,3 3,3

clear all;

p = gcp('nocreate'); % If no pool, do not create new one.

if isempty(p)
    c = parcluster;
    c.NumWorkers = 9;
    c.parpool(9); % MPI_INIT
end

NPD = [3 3]; % Número de elementos COL ROW

h = 1;

spmd(9)
    pid = spmdIndex; % MPI_Comm_rank 
    NP = spmdSize; % MPI_Comm_size
    if prod(NPD) ~= NP
        exit
    end

    ind = id2ind(pid, NPD);
    % dato local
    local = pid;

    % Vecinos
    cell_right = desplazamiento(ind, [1 0], NPD);
    cell_left = desplazamiento(ind, [-1 0], NPD);
    cell_up = desplazamiento(ind, [0 -1], NPD);
    cell_down = desplazamiento(ind, [0 1], NPD);

    p_right = ind2id(cell_right, NPD);
    p_left = ind2id(cell_left, NPD);
    p_up = ind2id(cell_up, NPD);
    p_down = ind2id(cell_down, NPD);

    % Envio derecha
    dato_right = spmdSendReceive(p_right, p_left, local);
    
    % Envio izquierda
    dato_left = spmdSendReceive(p_left, p_right, local);

    % Envio arriba
    dato_up = spmdSendReceive(p_up, p_down, local);

    % Envio arriba
    dato_down = spmdSendReceive(p_down, p_up, local);

    laplace = h * (dato_right + dato_left + dato_up + dato_down);
    display(laplace)
end

function ind = id2ind(pid, NPD)
    id = pid - 1;
    ind(1) = mod(int32(id), int32(NPD(1))) + 1; % COL
    ind(2) = idivide(int32(id), int32(NPD(1))) +1; % row
end

function id = ind2id(ind, NPD)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
    id = (ind(2) - 1) * NPD(1) + ind(1);
end

function result = desplazamiento(origen, delta, NPD)
    result(1) = mod(int32(origen(1)-1) + int32(delta(1)), int32(NPD(1))) + 1;
    result(2) = mod(int32(origen(2)-1) + int32(delta(2)), int32(NPD(2))) + 1;
end