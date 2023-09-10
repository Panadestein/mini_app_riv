module riv_utils
    use kinds
    use lapack_interfaces
    implicit none
    
    private
    public riv_compute_ovlp

contains
    
    subroutine riv_compute_ovlp(nb, n_aux, n_points, psi, aux, part_atoms, ovlp_3fn)
        integer, intent(in)                            :: nb, n_aux, n_points   
        real(kind=dp), dimension(:, :), intent(in)     :: psi
        real(kind=dp), dimension(:, :), intent(in)     :: aux
        real(kind=dp), dimension(:, :, :), intent(in)  :: part_atoms
        real(kind=dp), dimension(:, :), intent(inout)  :: ovlp_3fn

        ! Internal variables
        integer                                  :: k
        real(kind=dp), dimension(nb * nb)        :: psi_x_psi
        real(kind=dp), dimension(nb * nb, n_aux) :: psi_x_psi_x_aux

        ! Start computation
        do k = 1, n_points
            call dger(nb, nb, 1.0_dp, psi(:, k), 1, psi(:, k), 1, psi_x_psi(:), nb) ! Outer (mn)
            call dger(nb * nb, n_aux, 1.0_dp, psi_x_psi(:), 1, aux(:, k), 1, psi_x_psi_x_aux(:, :), nb * nb) ! Outer (mn|P)
            ovlp_3fn(:, :) = ovlp_3fn(:, :) + psi_x_psi_x_aux(:, :) * part_atoms(:, :, k) ! Hadamard
        end do
        
    end subroutine riv_compute_ovlp
    
end module riv_utils

program riv_miniapp
    use kinds
    use riv_utils
    implicit none

    ! Dummy example
    integer, parameter :: nb = 100
    integer, parameter :: n_aux = 50
    integer, parameter :: n_points = 100
    real(kind=dp), dimension(nb, n_points)             :: psi = 1.0_dp
    real(kind=dp), dimension(n_aux, n_points)          :: aux = 0.5_dp
    real(kind=dp), dimension(nb * nb, n_aux, n_points) :: part_atoms = 1.0_dp
    real(kind=dp), dimension(nb * nb, n_aux)           :: ovlp_3fn

    ! Compute RIV tensor
    call riv_compute_ovlp(nb, n_aux, n_points, psi, aux, part_atoms, ovlp_3fn)
    
end program riv_miniapp