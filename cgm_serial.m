% Sistema de Ecuaciones Alebraico A x = b
% A matriz de NxN
% x, b vectores de Nx1


function x = CGM(A, b)
    N = length(b);

    x = zeros(N);
    r = b;
    p = r;
    
    for n = 1:N % Exacto
        Ap = A * p; % TODO: paralelizar
        rr = dot(r,r);
        alph_a = rr/dot(p,AP);
        x = x + alph_a*p;
        r = r - alph_a*AP;
        bet_a = dot(r,r)/rr;
        p = r + bet_a * p;
    end
end
        