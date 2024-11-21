p = gcp('nocreate'); % If no pool, do not create new one.

if isempty(p)
    c = parcluster;
    c.NumWorkers = 8;
    c.parpool(8); % MPI_INIT
end


% Arbol
spmd
    pid = spmdIndex;
    NP = spmdSize;
    levels = floor(log2(NP));
    P = floor(log2(pid-1));
    %display([pid,P]);
    %display(levels);
    switch P
        case -Inf
            datos = 1:(2^levels);
            display(datos);
            left_init = 0;
            right_end = length(datos);
            for i = 1:levels
                left_end = length(right_end)/2;
                right_init = left_end + 1;
                spmdSend(datos(right_init, right_end), 2^i);
            end
        case 0
            display(mod(pid,));
        case 1
            display(mod(pid,2));
        case 2
            display(mod(pid,2));
    end
end
