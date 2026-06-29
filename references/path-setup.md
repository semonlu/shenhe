# PATH Setup

## Required PATH Entries

Add these directories to user PATH when they exist:

```text
E:\R-4.4.2\bin
E:\rtools44\usr\bin
E:\rtools44\x86_64-w64-mingw32.static.posix\bin
C:\rtools44\usr\bin
C:\rtools44\x86_64-w64-mingw32.static.posix\bin
C:\Program Files\Git\usr\bin
C:\ProgramData\miniconda3
C:\ProgramData\miniconda3\Scripts
C:\ProgramData\miniconda3\condabin
```

Also add JAGS if installed, commonly:

```text
C:\Program Files\JAGS\JAGS-4.3.1\x64\bin
C:\Program Files\JAGS\JAGS-4.3.1\bin
```

## Verification Commands

```powershell
Rscript --version
where.exe Rscript
where.exe make
where.exe gcc
where.exe gzip
conda --version
conda run -n seuratv5-course-py python -c "import scanpy, celltypist; print('ok')"
```

## Notes

- Put R 4.4.2 before older Conda R entries so `Rscript` resolves to the correct runtime.
- Rtools must match R 4.4.x. Use Rtools44 for this course.
- If package compilation fails, check that `make`, `gcc`, and `g++` resolve from Rtools44.
- If JAGS-linked packages fail, install JAGS and restart the shell after PATH changes.
