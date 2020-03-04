{ stdenv, fetchurl, fetchFromGitHub, ant, gradle, jdk, bash, coreutils, substituteAll }:

let
  freenet_ext = fetchurl {
    url = https://downloads.freenetproject.org/latest/freenet-ext.jar;
    sha256 = "0000000000000000000000000rknysz3x6igx8vl3xgdpvbb7wij";
  };

  bcprov_version = "jdk15on-164";
  bcprov = fetchurl {
    url = "https://www.bouncycastle.org/download/bcprov-ext-${bcprov_version}.jar";
    sha256 = "000000000000000000000000000000000000000000k1am0633jk";
  };
  seednodes = fetchurl {
    url = https://downloads.freenetproject.org/alpha/opennet/seednodes.fref;
    sha256 = "08awwr8n80b4cdzzb3y8hf2fzkr1f2ly4nlq779d6pvi5jymqdvv";
  };
  version = "build01485";

  freenet-jars = stdenv.mkDerivation {
    pname = "freenet-jars";
    inherit version;

    src = fetchFromGitHub {
      owner = "freenet";
      repo = "fred";
      rev = version;
      sha256 = "0000000000000000000000000000ibb0rmm4qdwr5xm28hy1nd08";
    };

    patchPhase = ''
      cp ${freenet_ext} lib/freenet/freenet-ext.jar
      cp ${bcprov} lib/bcprov-${bcprov_version}.jar

      sed '/antcall.*-ext/d' -i build.xml
      sed 's/@unknown@/${version}/g' -i build-clean.xml
    '';

    buildInputs = [ ant jdk ];

    buildPhase = "ant package-only";

    installPhase = ''
      mkdir -p $out/share/freenet
      cp lib/bcprov-${bcprov_version}.jar $out/share/freenet
      cp lib/freenet/freenet-ext.jar $out/share/freenet
      cp dist/freenet.jar $out/share/freenet
    '';
  };

in stdenv.mkDerivation {
  name = "freenet-${version}";
  inherit version;

  src = substituteAll {
    src = ./freenetWrapper;
    inherit bash coreutils seednodes bcprov_version;
    freenet = freenet-jars;
    jre = jdk.jre;
  };

  jars = freenet-jars;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/freenet
    chmod +x $out/bin/freenet
    ln -s ${freenet-jars}/share $out/share
  '';

  meta = {
    description = "Decentralised and censorship-resistant network";
    homepage = https://freenetproject.org/;
    license = stdenv.lib.licenses.gpl2Plus;
    maintainers = [ stdenv.lib.maintainers.doublec ];
    platforms = with stdenv.lib.platforms; linux;
  };
}
