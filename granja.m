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

spmd
    pid = spmdIndex; % MPI_RANK
    NP = spmdSize; % MPI_SIZE
    NT = NP - 1;
    if pid == 1 % Farmer
        MAX_tareas = 10;
        tareas = 0;
        ocupados = 0;
        datos = randi(10,1,MAX_tareas);
        % Primera etapa
        for p = 1:NT
            spmdSend(datos(tareas+1), p+1, TAG_DATOS);
            tareas = tareas+1;
            ocupados = ocupados+1;
        end

        while (ocupados > 0)
            [result, source, protocolo] = spmdReceive("any",TAG_RESULTADOS);
            ocupados = ocupados -1;
            if tareas < MAX_tareas
                % Segunda Etapa Trabajo sostenido
                spmdSend(datos(tareas+1), source, TAG_DATOS);
                tareas = tareas+1;
                ocupados = ocupados+1;
            else
                % Tercera Etapa, Terminacion
                spmdSend(0,source,TAG_CONTRON);
            end
        end
    else % Worker  
        [data, origen, protocolo] = spmdReceive(FARMER_PID);
        while (protocolo == TAG_DATOS) 
            fprintf("Pausa de %d segundos\n", data);
            pause(data)
            spmdSend(data, FARMER_PID, TAG_RESULTADOS);
            [data, origen, protocolo] = spmdReceive(FARMER_PID);
        end
    end
    fprintf("Fin, pid=%d\n",pid)
end