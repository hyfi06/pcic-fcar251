# mpiexec -n 4 python mpi.py 
from mpi4py import MPI

comm = MPI.COMM_WORLD # MPI_INIT
pid = comm.Get_rank() # MPI_COMM_RANK
NP = comm.Get_size() # PI_COMM_SIZE

#SPMD

if pid == 0: # Master
    print(f"Master pid {pid}")
    data = [1,2,3,4]
    req = comm.isend(data,1,1)
    print(req.get_status())
    data2 = req.wait()
elif pid == 1: # Workers
    print(f"Worker pid {pid}")
    req = comm.irecv(source=0,tag=1)
    data = req.wait()
    print(data)