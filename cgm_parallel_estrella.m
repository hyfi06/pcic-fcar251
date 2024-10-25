% matriz tres diagonales -441, 882, -441

p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool(4); % MPI_INIT
end

%Datos
fileName = 'cgm_datos_matlab.mat';

NGL = 20;


spmd
    pid = spmdIndex; % MPI_RANK
    NP = spmdSize; % MPI_SIZE
    if pid == 1
        A = leer_matriz(fileName,pid,NP);
        b = leer_vector(fileName);
        %preciclo
        x = zeros(size(b));
        r = b;
        p = r;
        for i = 1:NGL
            temp = spmdBroadcast(1,p);
            v = A*p;
            AP = spmdCat(v,1,1);
            rr = dot(r,r);
            alph_a = rr/dot(p,AP);
            x = x + alph_a*p;
            r = r - alph_a*AP;
            bet_a = dot(r,r)/rr;
            p = r + bet_a * p;
        end
        display(x);
    else
        for i =1:NGL
            A = leer_matriz(fileName,pid,NP);
            p = spmdBroadcast(1);
            v = A*p;
            spmdCat(v,1,1);
        end
    end
end

function A = leer_matriz(archivo, pid, NP)
    datos = load(archivo);
    steps = round(length(datos.A)/(NP)); % master sí participa
    idx = (1:steps) + (pid - 1) * 5; % master sí participa
    if pid == NP
        A = datos.A(idx(1):length(datos.A), :);
    else
        A = datos.A(idx,:);
    end
end

function b = leer_vector(archivo)
    datos = load(archivo);
    b = datos.b';
end