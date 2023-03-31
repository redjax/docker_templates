from pathlib import Path
from typing import Dict, List, Tuple, Optional
from datetime import timedelta
import json

import httpx
import httpx_cache


accepted_cache_types: List[str] = ["dict_cache", "file_cache"]


def raise_exc_on_400_500(response: httpx.Response = None):
    response.raise_for_status()


class ResponseObjBase:
    def __init__(
        self,
        status_code: int = None,
        reason_phrase: str = None,
        url: httpx.URL = None,
        headers: httpx.Headers = None,
        content: bytes = None,
        text: str = None,
        encoding: str = "utf-8",
        is_redirect: bool = False,
        request: httpx.Request = None,
        next_request: Optional[httpx.Request] = None,
        cookies: httpx.Cookies = False,
        history: List[httpx.Response] = None,
        elapsed: timedelta = None,
        _json: json = None,
    ):
        self.status_code = status_code
        self.reason_phrase = reason_phrase
        self.url = url
        self.headers = headers
        self.content = content
        self.text = text
        self.encoding = encoding
        self.is_redirect = is_redirect
        self.request = request
        self.next_request = next_request
        self.cookies = cookies
        self.history = history
        self.elapsed = elapsed
        self._json = _json

    @property
    def content_decoded(self) -> str:
        content_decoded = self.content.decode()

        return content_decoded


class ResponseObj(ResponseObjBase):
    pass


class RequestClientBase:
    def __init__(
        self,
        method: str = "GET",
        url: str = None,
        headers: Dict[str, str] = None,
        params: Dict[str, str] = None,
        auth_user: str = None,
        auth_password: str = None,
        auth_key: str = None,
        timeout: int = 10,
        use_cache: bool = True,
        cache_type: Optional[str] = "dict_cache",
        cache_dir: Optional[str] = "./req_cache",
        cache_max_age: Optional[int] = 900,
    ):
        self.method = method.upper()
        self.headers = headers
        self.url = url
        self.params = params
        self.auth_user = auth_user
        self.auth_password = auth_password
        self.auth_key = auth_key
        self.timeout = timeout
        self.use_cache = use_cache
        self.cache_type = cache_type
        self.cache_dir = cache_dir
        self.cache_max_age = cache_max_age

    def merge_headers(self, new_headers: dict = None):
        if new_headers is None:
            headers = self.headers

        else:
            headers = self.headers.update(new_headers)

        return headers

    @property
    def auth(self) -> Tuple[str, str]:
        if self.auth_user and self.auth_password:
            auth = (self.auth_user, self.auth_password)
        elif self.auth_user:
            auth = self.auth_user
        elif self.auth_password:
            auth = self.auth_password
        else:
            auth = None

        return auth

    @property
    def key(self) -> str:
        key = self.auth_key

        return key

    @property
    def client(self) -> httpx.Client | httpx_cache.Client:
        """
        Build an httpx.Client() object. If headers or params are detected,
        it will add them to the client.
        """

        if self.headers:
            if self.params:
                if self.auth:
                    client = httpx.Client(
                        headers=self.headers,
                        params=self.params,
                        auth=self.auth,
                        timeout=self.timeout,
                    )

                else:
                    ## "Headers and Params found for Client()"
                    client = httpx.Client(
                        headers=self.headers,
                        params=self.params,
                        timeout=self.timeout,
                    )

            else:
                if self.auth:
                    client = httpx.Client(
                        headers=self.headers,
                        auth=self.auth,
                        timeout=self.timeout,
                    )

                else:
                    ## "Headers found for Client()"
                    client = httpx.Client(
                        headers=self.headers,
                        timeout=self.timeout,
                    )

        else:
            if self.params:
                if self.auth:
                    client = httpx.Client(
                        params=self.params,
                        auth=self.auth,
                        timeout=self.timeout,
                    )

                else:
                    ## "Params found for Client()"
                    client = httpx.Client(
                        params=self.params,
                        timeout=self.timeout,
                    )

            else:
                ## "No Headers or Params found for Client()"
                client = httpx.Client(timeout=self.timeout)

        return client

    @property
    def async_client(self) -> httpx.AsyncClient:
        if self.headers:
            if self.params:
                async_client = httpx.AsyncClient(
                    headers=self.headers, params=self.params
                )

            else:
                async_client = httpx.AsyncClient(headers=self.headers)

        else:
            if self.params:
                async_client = httpx.AsyncClient(params=self.params)

            else:
                async_client = httpx.AsyncClient()

        return async_client

    @property
    def _cache(self) -> httpx_cache.DictCache | httpx_cache.FileCache:
        _type = self.cache_type

        if _type:
            if _type == "dict_cache":
                _cache_obj = httpx_cache.DictCache()

            elif _type == "file_cache":
                _cache_obj = httpx_cache.FileCache(cache_dir=self.cache_dir)

            else:
                raise ValueError(
                    f"This message shouldn't happen. cache_type var somehow passed validation."
                )

        else:
            return None

        return _cache_obj

    @property
    def cache_client(self) -> httpx_cache.Client:
        """
        Build an httpx.Client() object. If headers or params are detected,
        it will add them to the client.
        """

        if self.headers:
            headers = self.merge_headers(new_headers={"cache-control": "max-age=5"})
            if self.params:
                if self.auth:
                    cache_client = httpx_cache.Client(
                        headers=headers,
                        params=self.params,
                        auth=self.auth,
                        timeout=self.timeout,
                        cache=self._cache,
                    )

                else:
                    ## "Headers and Params found for Client()"
                    cache_client = httpx_cache.Client(
                        headers=headers,
                        params=self.params,
                        timeout=self.timeout,
                        cache=self._cache,
                    )

            else:
                if self.auth:
                    cache_client = httpx_cache.Client(
                        headers=headers,
                        auth=self.auth,
                        timeout=self.timeout,
                        cache=self._cache,
                    )

                else:
                    ## "Headers found for Client()"
                    cache_client = httpx_cache.Client(
                        headers=headers, timeout=self.timeout, cache=self._cache
                    )

        else:
            if self.params:
                if self.auth:
                    cache_client = httpx_cache.Client(
                        params=self.params,
                        auth=self.auth,
                        timeout=self.timeout,
                        cache=self._cache,
                    )

                else:
                    ## "Params found for Client()"
                    cache_client = httpx_cache.Client(
                        params=self.params, timeout=self.timeout, cache=self._cache
                    )

            else:
                ## "No Headers or Params found for Client()"
                cache_client = httpx_cache.Client(
                    timeout=self.timeout, cache=self._cache
                )

        return cache_client

    def get(self) -> ResponseObj:
        """
        https://www.python-httpx.org/async/
        """

        try:
            if not self.use_cache:
                if self.headers:
                    res = self.client.get(self.url, headers=self.headers)

                else:
                    res = self.client.get(self.url)

            else:
                if self.headers:
                    res = self.cache_client.get(self.url, headers=self.headers)

                else:
                    res = self.cache_client.get(self.url)

        finally:
            self.client.close()

        _res = ResponseObj(
            status_code=res.status_code,
            reason_phrase=res.reason_phrase,
            url=res.url,
            headers=res.headers,
            content=res.content,
            text=res.text,
            encoding=res.encoding,
            is_redirect=res.is_redirect,
            request=res.request,
            next_request=res.next_request,
            cookies=res.cookies,
            history=res.history,
            elapsed=res.elapsed,
            _json=res.json(),
        )

        return _res


class RequestClient(RequestClientBase):
    pass
