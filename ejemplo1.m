LABS = 4;
%parpool(LABS);

spmd
    pid = spmdIndex;
    NP = spmdSize;
    NW = NP - 1;
    if pid == 1
        fprintf('Hola! Soy el master, PID = %d',pid);
        data = 1:NW;
        for p = 1:NW
            spmdSend(data(p),p+1);
        end
        resultados = zeros(1,NW);
        for p = 10*1:NW
            [buffer,source] = spmdReceive("any",1);
            resultados(source) = buffer;
        end
        disp(resultados);
    else
        fprintf('Hola! Soy un worker, PID = %d',pid);
        [dato,source] = spmdReceive(1);
        fprintf('Dato = %d, Fuente = %d',dato,source);
        result = dato *2;
        spmdSend(dato,1);
    end
    fprintf("Fin, PID = %d",pid);
end