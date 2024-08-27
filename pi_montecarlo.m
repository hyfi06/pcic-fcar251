% parpool(4);

NUM_POINTS = 10000;

spmd
    pid = spmdIndex;
    NP = spmdSize;
    NW = NP - 1;
    if pid == 1
        points = NW * NUM_POINTS;
        seeds = rand(NW,1)*10000;
        np_circ = 0;
        spmdBroadcast(pid,NUM_POINTS);
        for i=1:NW
            spmdSend(seeds(i,1),i+1);
        end
        for i = 1:NW
            [dato,source] = spmdReceive("any",1);
            fprintf("Recibí %d de Worker %d\n",dato,source);
            np_circ = np_circ + dato;
        end
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
        x_y = rand(num_points,2);
        cir = 0;
        for i = 1:num_points
            if sqrt(x_y(i,1)^2 + x_y(i,2)^2) <= 1
                cir = cir + 1;
            end
        end
        spmdSend(cir,1,1);
    end
    fprintf("Fin, PID = %d\n",pid);
end

