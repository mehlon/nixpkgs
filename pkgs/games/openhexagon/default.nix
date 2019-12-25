{stdenv, fetchgit, makeWrapper, git, gnumake, gcc, cmake, fetchzip, sfml, zlib, lua5}:

stdenv.mkDerivation rec {
  pname = "openhexagon";
  version = "2.0";

  #fetchFromGitHub
  src = fetchgit {
    #leaveDotGit = true;
    fetchSubmodules = true;
    #deepClone = true;
    url = "https://github.com/mehlon/SSVOpenHexagon";
    rev = "a6abf3bcf41b4f6821c53f92a86f9b8c00ecbaad";
    sha256 = "0jkndf6gncv7a3bbm3v2ycx68s0hm9fbzxrd7z7pj6h3fwbvajq7";
  };

  buildInputs = [gnumake git cmake sfml lua5 zlib];
  #unpackPhase = "";
  #patchPhase = "";
  #postBuildHook = "";
  installPhase = ''
    mkdir -p $out/bin
    cp $src/openhexagon $out/bin/
    wrapProgram $out/bin/openhexagon --run "cd $out/share/openhexagon"
    mkdir -p $out/share/openhexagon/data
    cp -r $data/* $out/share/openhexagon/data
  '';

  meta = {
    description = ''Clone of Super Hexagon'';
    homepage = https://github.com/SuperV1234/SSVOpenHexagon;
    # license = stdenv.lib.licenses.gpl2;
  };
}
