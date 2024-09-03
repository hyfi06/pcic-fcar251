clear all;
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool('Threads', 7);
end

NUM_POINTS = 100000000;

spmd
    pid = spmdIndex;
    NP = spmdSize;
    if pid == 1
        t_init = tic;
        seeds = randi(10000, NP, 1);
        num_points = spmdBroadcast(pid, floor(NUM_POINTS/NP));
        points = NP*num_points;
        for i=2:NP
            spmdSend(seeds(i,1),i);
        end
        seed = seeds(1,1);
        rng(seed);
        circ = 0;
        for i = 1:num_points
            point = rand(2,1);
            d = sqrt(point(1,1)^2 + point(2,1)^2);  
            if d <= 1
                circ = circ + 1;
            end
        end
        np_circ = spmdPlus(circ,1);
        pi = 4 * np_circ / points;

        e_time = toc(t_init);
        fprintf("Puntos totales = %d\n",points);
        fprintf("Puntos locales = %d\n",num_points);
        fprintf("Total=%d\n",np_circ);
        fprintf("Pi = %f\n",pi);
        display(e_time);
    else
        num_points = spmdBroadcast(1);
        seed = floor(spmdReceive(1));
        rng(seed);
        %fprintf( ...
        %    "Iniciando PID = %d con seeed = %d y puntos %d\n", ...
        %    pid,seed,num_points ...
        %);
        circ = 0;
        for i = 1:num_points
            point = rand(2,1);
            d = sqrt(point(1,1)^2 + point(2,1)^2);  
            if d <= 1
                circ = circ + 1;
            end
        end
        %fprintf("Puntos locales: %d\n",circ);
        spmdPlus(circ,1);
    end
    %fprintf("Fin, PID = %d\n",pid);
end

