from pathlib import Path
from typing import Dict, List, Tuple, Optional, Union, Iterable
from datetime import timedelta
import json

from datetime import datetime, timedelta

import requests
import requests_cache


class ClientCacheBackendSQLiteBase:
    def __init__(
        self,
        cache_name: str = "http_cache",
        db_path: Union[Path, str] = None,
        use_cache_dir: str = None,
        use_temp: Optional[str] = None,
        wal: bool = True,
    ):
        self.cache_name = cache_name
        self.db_path = db_path
        self.use_cache_dir = use_cache_dir
        self.use_temp = use_temp
        self.wal = wal

    @property
    def sqlite_cache(self) -> requests_cache.SQLiteCache:
        if self.db_path:
            if self.db_path.endswith("/"):
                _cache = f"{self.db_path}{self.cache_name}"
            else:
                _cache = f"{self.db_path}/{self.cache_name}"

        cache = requests_cache.SQLiteCache(_cache, backend="sqlite")

        return cache


class ClientCacheBackendSQLite(ClientCacheBackendSQLiteBase):
    pass


class ClientCacheSettingsBase:
    def __init__(
        self,
        cache_name: str = None,
        cache_db_path: Optional[Union[Path, str]] = None,
        cache_use_cache_dir: Optional[str] = "./cache",
        cache_use_temp: Optional[str] = None,
        cache_wal: bool = True,
        backend_type: str = None,
        serializer: str = None,
        expire_after: Union[None, int, float, str, datetime, timedelta] = timedelta(
            days=140
        ),
        allowable_codes: Iterable[int] = [200],
        allowable_methods: Iterable[str] = ["GET"],
        always_revalidate: bool = False,
        stale_if_error: bool = True,
    ):
        self.cache_name = cache_name

        self.cache_db_path = cache_db_path
        self.cache_use_cache_dir = cache_use_cache_dir
        self.cache_use_temp = cache_use_temp
        self.cache_wal = cache_wal

        if backend_type in self.allowed_backends:
            self.backend_type = backend_type
        else:
            self.backend_type = "memory"

        if serializer in self.allowed_serializers:
            self.serializer = serializer
        else:
            self.serializer = "json"

        self.expire_after = expire_after
        self.allowable_codes = allowable_codes
        self.allowable_methods = allowable_methods
        self.always_revalidate = always_revalidate
        self.stale_if_error = stale_if_error

    @property
    def allowed_backends(self) -> List[str]:
        allowed_backends = [
            "sqlite",
            "filesystem",
            "mongodb",
            "gridfs",
            "redis",
            "dynamodb",
            "memory",
        ]

        return allowed_backends

    @property
    def allowed_serializers(self) -> List[str]:
        allowed_serializers = ["pickle", "json", "yaml", "bson"]

        return allowed_serializers

    @property
    def backend(self) -> requests_cache.SQLiteCache:
        backend = ClientCacheBackendSQLite(
            db_path=self.cache_db_path,
            use_cache_dir=self.cache_use_cache_dir,
            use_temp=self.cache_use_temp,
            wal=self.cache_wal,
        )

        return backend.sqlite_cache


class ClientCacheSettings(ClientCacheSettingsBase):
    pass


class ClientResponseBase:
    def __init__(
        self,
        status_code: int = None,
        content: Optional[bytes] = None,
        next: Optional[requests_cache.CachedRequest] = None,
        created_at: Optional[datetime] = None,
        elapsed: Optional[timedelta] = None,
        encoding: Optional[str] = None,
        expires: Optional[datetime] = None,
        headers: dict = None,
        history: Optional[List[requests_cache.CachedResponse]] = None,
        reason: Optional[str] = None,
        request: requests.Request | requests_cache.CachedRequest = None,
        url: Optional[str] = None,
        from_cache: bool = None,
        _json: json = None,
        ok: bool = None,
        revalidated: bool = None,
        size: int = None,
    ):
        self.status_code = status_code
        self.content = content
        self.next = next
        self.created_at = created_at
        self.elapsed = elapsed
        self.encoding = encoding
        self.expires = expires
        self.headers = headers
        self.history = history
        self.reason = reason
        self.request = request
        self.url = url
        self.from_cache = from_cache
        self._json = _json
        self.ok = ok
        self.revalidated = revalidated
        self.size = size

    @property
    def content_decoded(self) -> str:
        content_decoded = self.content.decode()

        return content_decoded


class ClientResponse(ClientResponseBase):
    pass


class RequestClientBase:
    def __init__(
        self,
        url: str = None,
        headers: Dict[str, str] = None,
        use_cache: bool = False,
        expire_after: int = 900,
        only_if_cached: bool = False,
        refresh: bool = False,
        force_refresh: bool = False,
        allowable_methods: Optional[Tuple] = ("GET", "POST"),
        auth: Optional[Tuple[str, str]] = None,
        key: str = None,
        cache_settings: Optional[ClientCacheSettings] = None,
        cache_backend: Union[
            ClientCacheBackendSQLite, requests_cache.SQLiteCache
        ] = None,
    ):
        self.url = url
        self.headers = headers
        self.use_cache = use_cache
        self.expire_after = expire_after
        self.only_if_cached = only_if_cached
        self.refresh = refresh
        self.force_refresh = force_refresh
        self.allowable_methods = allowable_methods
        self.auth = auth
        self.key = key
        self.cache_settings = cache_settings
        self.cache_backend = cache_backend

    @property
    def session(self) -> requests.Session | requests_cache.CachedSession:
        if self.use_cache == True:
            session = requests_cache.CachedSession(
                expire_after=self.expire_after,
                only_if_cached=self.only_if_cached,
                refresh=self.refresh,
                force_refresh=self.force_refresh,
                headers=self.headers,
            )

        else:
            session = requests.Session()

        return session

    def build_response_object(
        self,
        res: requests.Response | requests_cache.CachedResponse,
    ) -> ClientResponse:
        if self.use_cache == True:
            _created_at = res.created_at
            _expires = res.expires
            _from_cache = res.from_cache
        else:
            _created_at = None
            _expires = None
            _from_cache = False

        _res = ClientResponse(
            status_code=res.status_code,
            content=res.content,
            next=res.next,
            created_at=_created_at,
            elapsed=res.elapsed,
            encoding=res.encoding,
            expires=_expires,
            headers=res.headers,
            history=res.history,
            request=res.request,
            from_cache=_from_cache,
            ok=res.ok,
            _json=res.json(),
            size=res.size,
        )

        return _res

    def get(self, params: Dict[str, str] = None, **kwargs) -> ClientResponse:
        try:
            res = self.session.get(self.url, params=params, **kwargs)
            print(f"Results type: {type(res)}")
        finally:
            self.session.close()

        _res = self.build_response_object(res=res)

        return _res


class RequestClient(RequestClientBase):
    pass
