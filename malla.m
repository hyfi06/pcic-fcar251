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

NPD = [3, 3]; % Número de elementos 

spmd(9)
    pid = spmdIndex; % MPI_Comm_rank 
    NP = spmdSize; % MPI_Comm_size
    if prod(NPD) ~= NP
        exit
    end
    ind = id2ind(pid,NPD);
    display(ind);
    % dato local
    local = pid;
    ind_left = ind - [1 0];
    ind_up = ind - [0 1];
    ind_down = ind + [0 1];
    ind_right = ind + [1 0];
    
    
    % Envio derecha
    %dato_right = spmdSendReceive(p_right,p_left,local);


end

function ind = id2ind(pid, NPD)
    id = pid-1;
    ind(2) = idivide(int32(id), int32(NPD(2))) +1;
    ind(1) = mod(int32(id), int32(NPD(1))) + 1;
end

function id = ind2id(ind,NPD)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
    id = (int32(ind(2)) - 1) * int32(NPD(1));
end

function result = nod(ind,incremento,NPD) 
    result = ind + incremento;
    result = [mod(result(0)-1,NPD(1)) mod((result(0)-1),NPDs(2))];
end