clear all;
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool(8); % MPI_INIT
end

%Protocolos
TAG_DATOS = 1;
TAG_RESULTADOS = 2;

seed = 1000; % Para reproducir el mismo resultado en pruebas

spmd
    pid = spmdIndex; % MPI_RANK
    NP = spmdSize; % MPI_SIZE
    switch pid
        case 1
            % datos
            rng(seed) % Para reproducir el mismo resultado en pruebas
            datos =  randi(1000, NP*11, 1);
            display(datos);
            dest = [2 3 5];
            pivotes = zeros(length(dest)); % pila de pivotes, se requieren para unir después los resultados.
            % divide
            for p = 1:length(dest)
                pivote = datos(length(datos)); % escogemos el pivote
                datos = datos(1:length(datos)-1); % quitamos el pivote
                pivotes(p) = pivote; % guardamos el pivote
                % dividimos los datos por el pivote  
                left = datos(datos <= pivote); 
                right = datos(datos > pivote);
                spmdSend(left, dest(p), TAG_DATOS); % enviamos datos
                datos = right; % actualizamos el rango que se procesan en la siguiente iteración
            end
            % Procesar
            datos = sort(datos); % se puede usar el mismo Quick Sort de manera local para ordenar los datos locales. Por simplicidad se usa la función de Matlab.
            % Unir
            for p = length(dest):-1:1
                left = spmdReceive(dest(p),TAG_RESULTADOS);
                datos = [left; pivotes(p); datos]; % Unimos los datos ordenados con el pivote en medio.
            end
            display(datos);
        case 2
            datos = spmdReceive(1,TAG_DATOS);
            % divide
            dest = [4 7];
            pivotes = zeros(length(dest));
            for p = 1:length(dest)
                pivote = datos(length(datos));
                datos = datos(1:length(datos)-1);
                pivotes(p) = pivote;
                left = datos(datos <= pivote);
                right = datos(datos > pivote);
                spmdSend(left,dest(p),TAG_DATOS);
                datos = right;
            end
            % Procesar
            datos = sort(datos);
            % Unir
            for p = length(dest):-1:1
                left = spmdReceive(dest(p),TAG_RESULTADOS);
                datos = [left; pivotes(p); datos];
            end
            spmdSend(datos,1,TAG_RESULTADOS);
        case 3
            datos = spmdReceive(1,TAG_DATOS);
            % divide
            dest = 6;
            pivote = datos(length(datos));
            datos = datos(1:length(datos)-1);
            left = datos(datos <= pivote);
            right = datos(datos > pivote);
            spmdSend(left, dest, TAG_DATOS);
            datos = right;
            % Procesar
            datos = sort(datos);
            % Unir
            left = spmdReceive(dest,TAG_RESULTADOS);
            res = [left; pivote; datos];
            spmdSend(res,1,TAG_RESULTADOS);

        case 4
            datos = spmdReceive(2,TAG_DATOS);
            % divide
            dest = 8;
            pivote = datos(length(datos));
            datos = datos(1:length(datos)-1);
            left = datos(datos <= pivote);
            right = datos(datos > pivote);
            spmdSend(left,dest,TAG_DATOS);
            datos = right;
            % Procesar
            datos = sort(datos);
            % Unir
            left = spmdReceive(dest,TAG_RESULTADOS);
            res = [left; pivote; datos];
            spmdSend(res,2,TAG_RESULTADOS);

        case 5
            datos = spmdReceive(1,TAG_DATOS);
            % Procesar
            datos = sort(datos);
            % Unir
            spmdSend(datos, 1, TAG_RESULTADOS);

        case 6
            datos = spmdReceive(3,TAG_DATOS);
            % Procesar
            datos = sort(datos);
            % Unir
            spmdSend(datos, 3, TAG_RESULTADOS);

        case 7
            datos = spmdReceive(2,TAG_DATOS);
            % Procesar
            datos = sort(datos);
            % Unir
            spmdSend(datos, 2, TAG_RESULTADOS);

        case 8
            datos = spmdReceive(4,TAG_DATOS);
            % Procesar
            datos = sort(datos);
            % Unir
            spmdSend(datos, 4, TAG_RESULTADOS);
            
    end
end