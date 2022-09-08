{ pkgs ? import <nixpkgs> {}}:

with pkgs;
let
  pythonPackages = python3Packages;
  nvidiaPackages = pkgs:
      with pkgs; [
        cudaPackages_10_2.cudatoolkit
        cudaPackages.cudnn
      ];
  requiredPackags = [
    pipenv
    python38
    git
    stdenv
    pythonPackages.venvShellHook
  ];
in pkgs.mkShell rec {
  name = "impurePythonEnv";
  venvDir = "/home/sarios/playground/python/stable-diffusion/.venv";

  #nrizq2w7q86fgpbmcx178vv5s4hxdlfa-hello.dr Required for building C extensions
  CUDA_PATH = "${cudaPackages_10_2.cudatoolkit}";
  LD_LIBRARY_PATH = "${cudaPackages_10_2.cudatoolkit}/lib:${cudaPackages.cudnn}/lib:${cudaPackages_10_2.cudatoolkit.lib}/lib:${zlib}/lib:${stdenv.cc.cc.lib}/lib:/run/opengl-driver/lib:/run/opengl-driver-32/lib:/usr/lib:/usr/lib32:/run/opengl-driver/lib:/run/opengl-driver-32/lib:/usr/lib:/usr/lib32 :$LD_LIBRARY_PATH";

  buildInputs = requiredPackags ++ (nvidiaPackages pkgs);

  # Run this command, only after creating the virtual environment
  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    cd /home/sarios/playground/python/stable-diffusion/
    pip install -r smaller_freeze_requirements.txt
  '';

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ''
    # allow pip to install wheels
    unset SOURCE_DATE_EPOCH
  '';
}
