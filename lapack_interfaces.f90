module lapack_interfaces
  implicit none

  interface blas3
     subroutine dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
       use kinds, only: dp
       implicit none
       integer                      :: len
       character(len=1), intent(in) :: transa, transb
       integer, intent(in)          :: m, n, k, lda, ldb, ldc
       real(kind=dp), intent(in)    :: alpha, beta
       real(kind=dp), intent(in)    :: a(lda, *), b(ldb, *)
       real(kind=dp), intent(inout) :: c(ldc, *)
     end subroutine dgemm

     subroutine dger(m, n, alpha, x, incx, y, incy, a, lda)
       use kinds, only: dp
       implicit none
       integer, intent(in)           :: m, n, incx, incy, lda
       real(kind=dp), intent(in)     :: alpha
       real(kind=dp), intent(in)     :: x(*), y(*)
       real(kind=dp), intent(inout)  :: a(lda, *)
     end subroutine dger
  end interface

end module lapack_interfaces
  