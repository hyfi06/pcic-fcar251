% matriz tres diagonales -441, 882, -441

p = gcp('nocreate'); % If no pool, do not create new one.

if isempty(p)
    parpool(4); % MPI_INIT
end

%Datos
fileName = 'cgm_datos_matlab.mat';

spmd
    pid = spmdIndex; % MPI_RANK
    NP = spmdSize; % MPI_SIZE
    [A, b] = leer_datos(fileName, pid, NP);
    NGL = spmdPlus(length(b)); %MPI_Allreduce MPI_SUM

    % preciclo
    x = zeros(size(b));
    r = b;
    p = r;
    
    % ciclo
    for i = 1:1%NGL
        % Apha
        local_rr = dot(r,r);
        rr = spmdPlus(local_rr); %MPI_Allreduce MPI_SUM
        
        global_p = spmdCat(p,1);
        Ap = A*global_p; % local
        local_pAp = dot(p,Ap);
        pAp = spmdPlus(local_pAp);
        
        alph_a = rr/pAp;
        % x
        x = x + alph_a*p;

        r = r - alph_a*AP;
        %bet_a = dot(r,r)/rr;
        %p = r + bet_a * p;
    end
end


function [A,b] = leer_datos(archivo, pid, NP)
    datos = load(archivo);
    steps = round(length(datos.A)/(NP));
    idx = (1:steps) + (pid - 1) * steps;
    b = datos.b';
    if pid == NP
        A = datos.A(idx(1):length(datos.A), :);
        b = b(idx(1):length(datos.A));
    else
        A = datos.A(idx,:);
        b = b(idx);
    end
end