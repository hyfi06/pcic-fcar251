p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool('local',4);
end

NUM_POINTS = 1000000;

spmd
    pid = spmdIndex;
    NP = spmdSize;
    if pid == 1
        points = NP * NUM_POINTS;
        seeds = randi(10000, NP, 1);
        spmdBroadcast(pid, NUM_POINTS);
        for i=2:NW
            spmdSend(seeds(i,1),i);
        end
        seed = seeds(1,1);
        np_circ = spmdPlus(0,1);
        fprintf("Total=%d\n",np_circ);
        pi = 4 * np_circ / points;
        fprintf("Pi = %f\n",pi);
    else
        num_points = spmdBroadcast(1);
        seed = floor(spmdReceive(1));
        rng(seed);
        fprintf( ...
            "Iniciando PID = %d con seeed = %d y puntos %d\n", ...
            pid,seed,num_points ...
        );
        circ = 0;
        for i = 1:num_points
            point = rand(2,1);
            d = sqrt(point(1,1)^2 + point(2,1)^2);  
            if d <= 1
                circ = circ + 1;
            end
        end
        fprintf("Puntos locales: %d\n",circ);
        spmdPlus(circ,1);
    end
    fprintf("Fin, PID = %d\n",pid);
end

rut