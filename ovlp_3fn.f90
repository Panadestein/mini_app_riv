module riv_utils
   use kinds
   use lapack_interfaces
   use, intrinsic :: iso_c_binding
   implicit none

   private

   interface
      subroutine riv_compute_ovlp_gpu(nb, n_aux, n_points, psi, aux, part_atoms, ovlp_3fn) bind(C, name="riv_compute_ovlp_gpu")
         import :: c_int, c_double

         integer(c_int), value, intent(in)          :: nb, n_aux, n_points
         real(c_double), dimension(*), intent(in)   :: psi, aux, part_atoms
         real(c_double), dimension(*), intent(inout) :: ovlp_3fn

      end subroutine riv_compute_ovlp_gpu
   end interface

   public :: riv_compute_ovlp, riv_compute_ovlp_gpu

contains

   subroutine riv_compute_ovlp(nb, n_aux, n_points, psi, aux, part_atoms, ovlp_3fn)
      integer, intent(in)                           :: nb, n_aux, n_points
      real(kind=dp), dimension(:, :), intent(in)    :: psi
      real(kind=dp), dimension(:, :), intent(in)    :: aux
      real(kind=dp), dimension(:, :, :), intent(in) :: part_atoms
      real(kind=dp), dimension(:, :), intent(inout) :: ovlp_3fn

      ! Internal variables
      integer                                     :: k
      real(kind=dp), dimension(:), allocatable    :: psi_x_psi
      real(kind=dp), dimension(:, :), allocatable :: psi_x_psi_x_aux

      ! Initialize for dger
      allocate(psi_x_psi(nb * nb))
      allocate(psi_x_psi_x_aux(nb * nb, n_aux))

      psi_x_psi = 0.0_dp
      psi_x_psi_x_aux = 0.0_dp

      ! Start computation
      do k = 1, n_points
         call dger(nb, nb, 1.0_dp, psi(:, k), 1, psi(:, k), 1, psi_x_psi, nb) ! Outer (mn)
         call dger(nb * nb, n_aux, 1.0_dp, psi_x_psi, 1, aux(:, k), 1, psi_x_psi_x_aux, nb * nb) ! Outer (mn|P)
         ovlp_3fn(:, :) = ovlp_3fn(:, :) + psi_x_psi_x_aux(:, :) * part_atoms(:, :, k) ! Hadamard
      end do

      ! Free memory
      deallocate(psi_x_psi)
      deallocate(psi_x_psi_x_aux)

   end subroutine riv_compute_ovlp

end module riv_utils

program riv_miniapp
   use kinds
   use riv_utils
   implicit none

   ! Constants
   logical, parameter       :: cmp_vals = .false.
   integer, parameter       :: nb = 300
   integer, parameter       :: n_aux = 100
   integer, parameter       :: n_points = 80
   real(kind=dp), parameter :: accuracy = 1.0e-6

   ! Internal variables
   integer                                        :: p, mn
   real(kind=dp), dimension(:, :), allocatable    :: psi
   real(kind=dp), dimension(:, :), allocatable    :: aux
   real(kind=dp), dimension(:, :, :), allocatable :: part_atoms
   real(kind=dp), dimension(:, :), allocatable    :: ovlp_3fn
   real(kind=dp), dimension(:, :), allocatable    :: ovlp_3fn_gpu
   real(kind=dp)                                  :: t_init, t_end, t_cpu, t_gpu

   ! Allocate ans initialize arrays
   allocate(psi(nb, n_points))
   allocate(aux(n_aux, n_points))
   allocate(part_atoms(nb * nb, n_aux, n_points))
   allocate(ovlp_3fn(nb * nb, n_aux))
   allocate(ovlp_3fn_gpu(nb * nb, n_aux))

   ! Initialize
   psi = 1.0_dp
   aux = 2.0_dp
   part_atoms = 3.0_dp
   ovlp_3fn = 0.0_dp
   ovlp_3fn_gpu = 0.0_dp

   ! Compute RIV tensor in the CPU
   call cpu_time(t_init)
   call riv_compute_ovlp(nb, n_aux, n_points, psi, aux, part_atoms, ovlp_3fn)
   call cpu_time(t_end)
   t_cpu = t_end - t_init

   ! Compute RIV tensor in the GPU
   call cpu_time(t_init)
   call riv_compute_ovlp_gpu(nb, n_aux, n_points, psi, aux, part_atoms, ovlp_3fn_gpu)
   call cpu_time(t_end)
   t_gpu = t_end - t_init

   print *, "T_cpu / T_gpu = ", t_cpu / t_gpu

   ! Compare values
   if (cmp_vals) then
      do p = 1, n_aux
         do mn = 1, nb * nb
            if (abs(ovlp_3fn(mn, p) - ovlp_3fn_gpu(mn, p)) > accuracy) then
               print *, "Matrix mismatch (BLAS/cuBLAS) at index (", mn, ",", p, "):",&
                  ovlp_3fn(mn, p), "vs", ovlp_3fn_gpu(mn, p)
            end if
         end do
      end do
   end if

   ! Free memory
   deallocate(psi)
   deallocate(aux)
   deallocate(part_atoms)
   deallocate(ovlp_3fn)

end program riv_miniapp
