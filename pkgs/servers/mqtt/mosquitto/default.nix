{ stdenv, lib, fetchFromGitHub, cmake, docbook_xsl, libxslt
, openssl, libuuid, libwebsockets_3_1, c-ares, libuv
, systemd ? null, withSystemd ? stdenv.isLinux }:

stdenv.mkDerivation rec {
  pname = "mosquitto";
  version = "1.6.5";

  src = fetchFromGitHub {
    owner  = "eclipse";
    repo   = "mosquitto";
    rev    = "v${version}";
    sha256 = "0scgsi3rvs9s8vxv4r7d5d9ixbsfg4dwnjcy6zxwdz9dfn8qnngj";
  };

  postPatch = ''
    for f in html manpage ; do
      substituteInPlace man/$f.xsl \
        --replace http://docbook.sourceforge.net/release/xsl/current ${docbook_xsl}/share/xml/docbook-xsl
    done

    for f in {lib,lib/cpp,src}/CMakeLists.txt ; do
      substituteInPlace $f --replace /sbin/ldconfig true
    done

    # the manpages are not generated when using cmake
    pushd man
    make
    popd
  '';

  buildInputs = [
    openssl libuuid libwebsockets_3_1 c-ares libuv
  ] ++ lib.optional withSystemd systemd;

  nativeBuildInputs = [ cmake docbook_xsl libxslt ];

  cmakeFlags = [
    "-DWITH_THREADING=ON"
    "-DWITH_WEBSOCKETS=ON"
  ] ++ lib.optional withSystemd "-DWITH_SYSTEMD=ON";

  meta = with stdenv.lib; {
    description = "An open source MQTT v3.1/3.1.1 broker";
    homepage = "https://mosquitto.org/";
    license = licenses.epl10;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
