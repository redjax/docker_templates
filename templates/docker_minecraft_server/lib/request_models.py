from pathlib import Path
from typing import Dict, List, Tuple, Optional
from datetime import timedelta
import json

import httpx


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
    ):
        self.method = method.upper()
        self.headers = headers
        self.url = url
        self.params = params
        self.auth_user = auth_user
        self.auth_password = auth_password
        self.auth_key = auth_key
        self.timeout = timeout

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
    def client(self) -> httpx.Client:
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

    def get(self):
        """
        https://www.python-httpx.org/async/
        """

        try:
            if self.headers:
                res = self.client.get(self.url, headers=self.headers)

            else:
                res = self.client.get(self.url)

        finally:
            self.client.close()

        # _res = res.json()

        # return _res

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
