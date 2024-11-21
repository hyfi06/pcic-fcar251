p = gcp('nocreate'); % If no pool, do not create new one.

if isempty(p)
    c = parcluster;
    c.NumWorkers = 8;
    c.parpool(8); % MPI_INIT
end

origen = [];
dest = [];
dest{1} = nan;
dest{1} = [2, 4, 8];
origen{2} = 1;
origen{3} = 2;

% Arbol
spmd
    pid = spmdIndex;
    NP = spmdSize;
    levels = floor(log2(NP));
    P = floor(log2(pid-1));
    switch pid
        case 1
            
        otherwise
            dato = spmdReceive(origen{pid});
    end
end
