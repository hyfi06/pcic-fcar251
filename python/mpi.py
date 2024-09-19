# mpiexec -n 4 python mpi.py 
from mpi4py import MPI

comm = MPI.COMM_WORLD # MPI_INIT
pid = comm.Get_rank() # MPI_COMM_RANK
NP = comm.Get_size() # PI_COMM_SIZE

#SPMD

if pid == 0: # Master
    print("Master pid {pid}")
else: # Workers
    print("Worker pid {pid}")