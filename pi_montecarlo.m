% Cálculo de PI por el método de Monte Carlo
% Paralización trivial con arquitectura estrella
% PI = 4 * Puntos_circulo  / Puntos_totales
% Puntos_circulo: Son los puntos aleatorios que se encuentran dentro
% del circulo y el primer cuadrante del plano carteciano

clear all;
PROCESADORES = 8;

p = gcp('nocreate'); % If no pool, do not create new one.

if isempty(p)
    c = parcluster;
    c.NumWorkers = PROCESADORES;
    c.parpool(PROCESADORES); % MPI_INIT
end

spmd
    pid = spmdIndex; % MPI_Comm_rank 
    NP = spmdSize; % MPI_Comm_size
    NW = NP - 1; % Número de trabajadores
    if pid == 1 % Master
        NUM_POINTS = 1000000; %Números de puntos para cada trabajdor
        points = NW * NUM_POINTS; % Puntos totales
        seeds = randi(10000, NW, 1); % se generan las semillas aleatorias
        % Se comunica el número de putos a procesar por cada trabajador
        spmdBroadcast(pid, NUM_POINTS); 
        for i=1:NW
            spmdSend(seeds(i,1),i+1); % se envía la semilla a cada trabajador
        end
        np_circ = spmdPlus(0,1); % MPI_Reduce con MPI_SUM
        pi = 4 * np_circ / points;

        fprintf("Puntos en el círculo=%d\n", np_circ);
        fprintf("Total de puntos procesados=%d\n", points);
        fprintf("Pi = %f\n",pi);
    else
        num_points = spmdBroadcast(1); % Recibe el número de puntos a procesar
        seed = floor(spmdReceive(1)); % Recibe la semilla
        rng(seed); % Se configura la semilla local
        % fprintf( ...
        %     "Iniciando PID = %d con seeed = %d y puntos %d\n", ...
        %     pid,seed,num_points ...
        % );
        circ = 0; % contador de puntos dentro del círculo
        for i = 1:num_points
            point = rand(2,1); % punto aleatorio
            d = sqrt(point(1,1)^2 + point(2,1)^2); % distancia al origien  
            if d <= 1 % está dentro del círculo
                circ = circ + 1;
            end
        end
        % fprintf("Puntos locales: %d\n",circ);
        spmdPlus(circ,1); % Se envía el resultado de puntos en el círculo
    end
    %fprintf("Fin, PID = %d\n",pid);
end

