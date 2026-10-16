{ pkgs }:
let
  inherit (pkgs) lib;
  release = builtins.fromJSON (builtins.readFile ./t3code-release.json);
  version = lib.removePrefix "v" release.tag_name;
  asset = name:
    let
      releaseAsset = lib.findFirst (a: a.name == name)
        (throw "T3 Code ${version} is missing ${name}") release.assets;
    in
    pkgs.fetchurl {
      url = releaseAsset.browser_download_url;
      sha256 = lib.removePrefix "sha256:" releaseAsset.digest;
    };
  platform = {
    aarch64-darwin = "darwin-arm64";
    aarch64-linux = "linux-arm64";
    x86_64-linux = "linux-x64";
  }.${pkgs.stdenv.hostPlatform.system};
  meta = {
    homepage = "https://t3.codes";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
  appimageSrc = asset "T3-Code-${version}-${if pkgs.stdenv.hostPlatform.isAarch64 then "arm64" else "x86_64"}.AppImage";
  appimageContents = pkgs.appimageTools.extractType2 {
    pname = "t3code-desktop";
    inherit version;
    src = appimageSrc;
  };
in
{
  cli = pkgs.stdenv.mkDerivation {
    pname = "t3code";
    inherit version;
    src = asset "t3-${version}-${platform}.tar.gz";
    dontStrip = true;
    nativeBuildInputs = [ pkgs.makeWrapper ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.stdenv.cc.cc.lib pkgs.openssl pkgs.zlib
    ];
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/libexec/t3code" "$out/bin"
      cp -R . "$out/libexec/t3code/"
      makeWrapper "$out/libexec/t3code/t3" "$out/bin/t3"
      runHook postInstall
    '';
    meta = meta // { mainProgram = "t3"; };
  };

  desktop = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.stdenvNoCC.mkDerivation {
    pname = "t3code-desktop";
    inherit version;
    src = asset "T3-Code-${version}-arm64.zip";
    nativeBuildInputs = [ pkgs.unzip pkgs.makeWrapper ];
    sourceRoot = ".";
    # Preserve the upstream app bundle and its code signature
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications" "$out/bin"
      apps=( *.app )
      test "''${#apps[@]}" -eq 1
      cp -R "''${apps[0]}" "$out/Applications/"
      makeWrapper "$out/Applications/''${apps[0]}/Contents/MacOS/"* \
        "$out/bin/t3code-desktop"
      runHook postInstall
    '';
    meta = meta // { mainProgram = "t3code-desktop"; };
  } else pkgs.appimageTools.wrapType2 {
    pname = "t3code-desktop";
    inherit version;
    src = appimageSrc;
    extraInstallCommands = ''
      mkdir -p "$out/share/applications"
      cp ${appimageContents}/*.desktop "$out/share/applications/t3code.desktop"
      sed -i 's|^Exec=.*|Exec=t3code-desktop %U|' "$out/share/applications/t3code.desktop"
      if [ -d ${appimageContents}/usr/share/icons ]; then
        cp -R ${appimageContents}/usr/share/icons "$out/share/"
      fi
    '';
    meta = meta // { mainProgram = "t3code-desktop"; };
  };
}
