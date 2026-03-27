| S6_PIP_PACKAGES          | empty string | **Space**-separated list of packages to install globally with `pip`.
| S6_PIP_REQUIREMENTS      | empty string | Path to `requirements.txt` to install globally with `pip`.
| S6_PIP_USER_PACKAGES     | empty string | **Space**-separated list of packages to install with `pip` for `${S6_USER}`. These are installed in `~/.local/`.
| S6_PIP_USER_REQUIREMENTS | empty string | Path to `requirements.txt` to install with `pip` for `${S6_USER}`.
| S6_UV_PACKAGES           | empty string | **Space**-separated list of packages to install globally with `uv`. {{ m.sincev('3.12.12_20260327') }}
| S6_UV_REQUIREMENTS       | empty string | Path to `requirements.txt` to install globally with `uv`. {{ m.sincev('3.12.12_20260327') }}
| S6_UV_LOCAL_PACKAGES     | empty string | **Space**-separated list of packages to install with `uv` for project set as `${UV_PROJECT}` (required). These are installed in `${UV_PROJECT}/.venv/`. {{ m.sincev('3.12.12_20260327') }}
| S6_SKIP_UV_SYNC          | empty string | By default, runs a sync if a `uv.lock` file is found in `${UV_PROJECT}` directory, setting this to e.g `1` skips that step. {{ m.sincev('3.12.12_20260327') }}
