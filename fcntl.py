"""Windows compatibility shim for the Unix fcntl module.
Provides flock, ioctl, and fcntl constants and functions for cross-platform compatibility.
"""
import sys

LOCK_SH = 1
LOCK_EX = 2
LOCK_NB = 4
LOCK_UN = 8

if sys.platform == "win32":
    import msvcrt
    import os

    def flock(fd, operation):
        """Emulate flock on Windows using msvcrt.locking."""
        if hasattr(fd, "fileno"):
            fileno = fd.fileno()
        else:
            fileno = int(fd)

        curr_pos = None
        try:
            curr_pos = os.lseek(fileno, 0, os.SEEK_CUR)
            os.lseek(fileno, 0, os.SEEK_SET)
        except OSError:
            pass

        try:
            if operation & LOCK_UN:
                try:
                    msvcrt.locking(fileno, msvcrt.LK_UNLCK, 1)
                except OSError:
                    pass
            elif operation & LOCK_NB:
                try:
                    msvcrt.locking(fileno, msvcrt.LK_NBLCK, 1)
                except OSError as e:
                    raise BlockingIOError(getattr(e, "errno", 11), "Resource temporarily unavailable") from e
            else:
                try:
                    msvcrt.locking(fileno, msvcrt.LK_LOCK, 1)
                except OSError:
                    pass
        finally:
            if curr_pos is not None:
                try:
                    os.lseek(fileno, curr_pos, os.SEEK_SET)
                except OSError:
                    pass

    def ioctl(fd, op, arg=0, mutable_flag=True):
        return 0

    def fcntl(fd, op, arg=0):
        return 0
else:
    from fcntl import *
