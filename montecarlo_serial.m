clear all;
NUM_POINTS = 100000000;

t_init = tic;
seeds = randi(10000, 1, 1);
points = NUM_POINTS;
seed = seeds(1,1);
rng(seed);
circ = 0;
for i = 1:points
    point = rand(2,1);
    d = sqrt(point(1,1)^2 + point(2,1)^2);  
    if d <= 1
        circ = circ + 1;
    end
end
pi = 4 * circ / points;

e_time = toc(t_init);
fprintf("Puntos totales = %d\n",points);
fprintf("Total=%d\n",circ);
fprintf("Pi = %f\n",pi);
display(e_time);
