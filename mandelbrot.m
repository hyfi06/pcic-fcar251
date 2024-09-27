clear all;
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool(4); % MPI_INIT
end

%Protocolos
TAG_DATOS = 1;
TAG_RESULTADOS = 2;
TAG_CONTRON = 3;

FARMER_PID = 1;

% Mandelbrot
HIGHT = 1000;
WIDTH = 1000;
X_RANGE = struct();
X_RANGE.min = -2;
X_RANGE.max = 2;
Y_RANGE = struct();
Y_RANGE.min = -2;
Y_RANGE.max = 2;
DX = (X_RANGE.max - X_RANGE.min)/(WIDTH-1);
DY = (Y_RANGE.max - Y_RANGE.min)/(HIGHT-1);


spmd
    pid = spmdIndex; % MPI_RANK
    NP = spmdSize; % MPI_SIZE
    NT = NP - 1;
    if pid == 1 % Farmer
        sTime = tic;
        MAX_tareas = HIGHT;
        tareas = 0;
        ocupados = 0;
        
        % Inicialización
        imagen_output = zeros(HIGHT,WIDTH);

        % Primera etapa
        for p = 1:NT
            spmdSend(tareas+1, p+1, TAG_DATOS);
            tareas = tareas+1;
            ocupados = ocupados+1;
        end

        while (ocupados > 0)
            [result, source, protocolo] = spmdReceive("any",TAG_RESULTADOS);
            imagen_output(result.row,:) = result.val;
            ocupados = ocupados - 1;
            if tareas < MAX_tareas
                % Segunda Etapa Trabajo sostenido
                spmdSend(tareas+1, source, TAG_DATOS);
                tareas = tareas+1;
                ocupados = ocupados+1;
            else
                % Tercera Etapa, Terminacion
                spmdSend(0,source,TAG_CONTRON);
            end
        end
        elapceTime = toc(sTime);
        fprintf("Tiempo de ejecución: %f", elapceTime);
    else % Worker  
        [data, origen, protocolo] = spmdReceive(FARMER_PID);
        while (protocolo == TAG_DATOS) 
            % fprintf("Procesando renglón %d\n", data);
            res = struct();
            res.y = X_RANGE.max - (DY * (data - 1));
            res.val = zeros(1,WIDTH);
            res.row = data;
            for col = 1:WIDTH
                res.val(1,col) = mandelbrot_pixel( ...
                    X_RANGE.min + (col-1)*DX + res.y * 1i ...
                );
            end
            spmdSend(res, FARMER_PID, TAG_RESULTADOS);
            [data, origen, protocolo] = spmdReceive(FARMER_PID);
        end
    end
    fprintf("Fin, pid=%d\n",pid)
end

function iter = mandelbrot_pixel(c)
    MAX_ITER = 256;
    z = 0+0i;
    iter = 0;
    while(abs(z) < 4 && iter < MAX_ITER)
        z = z^2 + c;
        iter = iter + 1;
    end
end