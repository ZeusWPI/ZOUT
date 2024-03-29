{
  description = "ZOUT";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, devshell, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ devshell.overlay ]; };
      in
      {
        devShells = rec {
          default = zout;
          zout = pkgs.devshell.mkShell {
            name = "ZOUT";
            packages = [
              pkgs.ffmpeg
              pkgs.nixpkgs-fmt
              pkgs.erlang
              pkgs.elixir_1_14
              (pkgs.postgresql_14.withPackages (p: [ p.timescaledb ]))
              pkgs.inotify-tools
              pkgs.nodejs-16_x
              pkgs.docker-compose
            ];
            env = [
              {
                name = "PGDATA";
                eval = "$PWD/tmp/postgres";
              }
              {
                name = "DATABASE_HOST";
                eval = "$PGDATA";
              }
            ];
            commands = [
              {
                name = "pg:setup";
                category = "database";
                help = "Setup postgres in project folder";
                command = ''
                  initdb --encoding=UTF8 --no-locale --no-instructions -U postgres
                  echo "unix_socket_directories = '$PGDATA'" >> $PGDATA/postgresql.conf
                  echo "shared_preload_libraries = 'timescaledb'" >> $PGDATA/postgresql.conf
                  echo "CREATE USER postgres WITH PASSWORD 'postgres' CREATEDB;" | postgres --single -E postgres
                  echo "CREATE DATABASE zout_dev;" | postgres --single -E postgres
                '';
              }
              {
                name = "pg:start";
                category = "database";
                help = "Start postgres instance";
                command = ''
                  [ ! -d $PGDATA ] && pg:setup
                  pg_ctl -D $PGDATA -U postgres start -l tmp/postgres.log
                '';
              }
              {
                name = "pg:stop";
                category = "database";
                help = "Stop postgres instance";
                command = ''
                  pg_ctl -D $PGDATA -U postgres stop
                '';
              }
              {
                name = "pg:console";
                category = "database";
                help = "Open database console";
                command = ''
                  psql --host $PGDATA -U postgres
                '';
              }
              {
                name = "link";
                category = "editor";
                help = "Create shortcuts for Intellij SDK";
                command = ''
                  mkdir -p "$PWD/tmp/current"
                  ln -sfn ${pkgs.erlang} "$PWD/tmp/current/erlang"
                  ln -sfn ${pkgs.elixir} "$PWD/tmp/current/elixir"
                '';
              }
              {
                name = "idea";
                category = "editor";
                help = "Start Intellij Ultimate (system) in this project";
                command = ''
                  link
                  idea-ultimate . >/dev/null 2>&1 &
                '';
              }
            ];
          };
        };
      }
    );
}
