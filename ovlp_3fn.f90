module riv_utils
   use kinds
   use lapack_interfaces
   use iso_c_binding
   implicit none

   private

   interface gpu_funcs
      subroutine riv_compute_ovlp_gpu(nb, n_aux, n_points, psi, aux, part_atoms, ovlp_3fn) bind(C, name="riv_compute_ovlp_gpu")
         import :: c_int, c_ptr

         integer(c_int), value, intent(in) :: nb, n_aux, n_points
         type(c_ptr), intent(in)           :: psi, aux, part_atoms
         type(c_ptr), intent(inout)        :: ovlp_3fn

      end subroutine riv_compute_ovlp_gpu
   end interface

   public :: riv_compute_ovlp, gpu_funcs

contains

   subroutine riv_compute_ovlp(nb, n_aux, n_points, psi, aux, part_atoms, ovlp_3fn)
      integer, intent(in)                                   :: nb, n_aux, n_points
      real(kind=dp), dimension(:, :), target, intent(in)    :: psi
      real(kind=dp), dimension(:, :), target, intent(in)    :: aux
      real(kind=dp), dimension(:, :, :), target, intent(in) :: part_atoms
      real(kind=dp), dimension(:, :), target, intent(inout) :: ovlp_3fn

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
   use iso_c_binding, only: c_ptr, c_loc
   implicit none

   ! Dummy example
   integer, parameter :: nb = 10
   integer, parameter :: n_aux = 10
   integer, parameter :: n_points = 10
   real(kind=dp), dimension(:, :), allocatable, target     :: psi
   real(kind=dp), dimension(:, :), allocatable, target     :: aux
   real(kind=dp), dimension(:, :, :), allocatable, target  :: part_atoms
   real(kind=dp), dimension(:, :), allocatable, target     :: ovlp_3fn
   type(c_ptr) :: cptr_psi, cptr_aux, cptr_part_atoms, cptr_ovlp_3fn

   ! Allocate ans initialize arrays
   allocate(psi(nb, n_points))
   allocate(aux(n_aux, n_points))
   allocate(part_atoms(nb * nb, n_aux, n_points))
   allocate(ovlp_3fn(nb * nb, n_aux))

   ! Initialize
   psi = 1.0_dp
   aux = 2.0_dp
   part_atoms = 3.0_dp
   ovlp_3fn = 0.0_dp

   ! Pointers to fortran arrays
   cptr_psi = c_loc(psi)
   cptr_aux = c_loc(aux)
   cptr_part_atoms = c_loc(part_atoms)
   cptr_ovlp_3fn = c_loc(ovlp_3fn)

   ! Compute RIV tensor
   call riv_compute_ovlp(nb, n_aux, n_points, psi, aux, part_atoms, ovlp_3fn)
   call riv_compute_ovlp_gpu(nb, n_aux, n_points, cptr_psi, cptr_aux, cptr_part_atoms, cptr_ovlp_3fn)

   ! Free memory
   deallocate(psi)
   deallocate(aux)
   deallocate(part_atoms)
   deallocate(ovlp_3fn)

end program riv_miniapp
