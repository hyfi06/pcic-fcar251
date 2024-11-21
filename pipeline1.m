p = gcp('nocreate'); % If no pool, do not create new one.

if isempty(p)
    c = parcluster;
    c.NumWorkers = 8;
    c.parpool(8); % MPI_INIT
end

LABEL_DATO = 1;
LABEL_TERMINACION = 2;

spmd
    pid = spmdIndex;
    NP = spmdSize;
    switch pid
        case 1 %Stream de datos
            datos = 1:4;
            for i = datos
                spmdSend(i,2,LABEL_DATO);
            end
            spmdSend(0,2,LABEL_TERMINACION);
        case NP
            datos = 1:10;
            [dato, origen, tag] = spmdReceive(pid-1);
            i=1;
            while tag == LABEL_DATO
                datos(i) = dato;
                i = i+1;
                [dato, origen, tag] = spmdReceive(pid-1);
            end
            display(datos);
        otherwise
            local = NaN;
            [dato, origen, tag] = spmdReceive(pid-1);
            while tag == LABEL_DATO
                if isnan(local)
                    local = dato;
                else
                    if local < dato
                        spmdSend(dato,pid+1);
                    else
                        spmdSend(local,pid+1)
                    end
                end
                [dato, origen, tag] = spmdReceive(pid-1);
                
            end
            spmdSend(0,pid+1,tag);
    end
end

function result = pipeline_subl (dato, pid)
    dato_local = NaN;

end