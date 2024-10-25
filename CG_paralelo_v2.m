clear all

%MPI INIT

%MPI COMM SIZE
NP = numlabs;

%MPI COMM RANK
pid = labindex;

%ARQUITECTURA SINCRONA

%DATOS 
archivo ='cgm_datos_matlab.mat'
NGL = 20;
NR = NGL/NP;
renglones  = (1:NR) + (pid -1)*NR;


%LEER MATRIZ

b = CGM_leerVector(archivo, renglones);
A = CGM_leerMatriz(archivo, renglones);


%PRECICLO

x = zeros(NR,1);
r = b;
p=r;


%CICLO 

for  n=1:NGL %GLOBAL

    %calcular ALFA
    %producto Ap
     Gp = gop(@vertcat, p);%ALL_GATHER

     Ap =A*Gp;
    %numerador
    Lrr = dot(r,r); %op local (subtotal)
    Grr = gop(@plus, Lrr); %ALL_REDUCE, GLOBAL

    % denominador
    LpAp = dot(p, Ap);
    GpAp = gop(@plus, LpAp);

    %Alfa
    alfa = Grr/GpAp;

    x = x + alfa*p;


    r= r-alfa*Ap;
    

    %BETA

    %numerador
    LrrN = dot(r, r);
    GrrN = gop(@plus, LrrN);

    %denominador
    %se reutiliza la variable Grr

    betta = GrrN/Grr;

    p = r+ betta*p;


end

disp(x)


















%MPI FINALIZE