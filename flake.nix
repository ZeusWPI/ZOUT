{
  description = "ZOUT";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, devshell, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ devshell.overlays.default ]; config.allowUnfree = true; };
      in
      {
        devShells = rec {
          default = zout;
          zout = pkgs.devshell.mkShell {
            name = "ZOUT";
            packages = [
              pkgs.ffmpeg
              pkgs.nixpkgs-fmt
              pkgs.erlang_27
              pkgs.elixir_1_18
              (pkgs.postgresql_17.withPackages (p: [ p.timescaledb ]))
              pkgs.inotify-tools
              pkgs.nodejs_22
              pkgs.docker-compose
            ];
            env = [
              {
                name = "PGDATA";
                eval = "$PRJ_DATA_DIR/postgres";
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
                  pg_ctl -D $PGDATA -U postgres start -l $PRJ_DATA_DIR/postgres.log
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
                  mkdir -p "$PRJ_DATA_DIR/current"
                  ln -sfn ${pkgs.erlang} "$PRJ_DATA_DIR/current/erlang"
                  ln -sfn ${pkgs.elixir} "$PRJ_DATA_DIR/current/elixir"
                '';
              }
            ];
          };
        };
      }
    );
}
