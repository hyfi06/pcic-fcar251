p = gcp('nocreate'); % If no pool, do not create new one.

if isempty(p)
    parpool("Threads",8); % MPI_INIT
end

% Arbol

spmd
    pid = spmdIndex;
    NP = spmdSize;
    
end