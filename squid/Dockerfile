# encoding: UTF-8
#
# Author:    Dave Syer <david_syer@hotmail.com>
# License:   Apache License, Version 2.0
# Copyright: (C) 2014-2015 Dave Syer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM       alpine:3.2
MAINTAINER Dave Syer <david_syer@hotmail.com>

RUN apk add --update squid
RUN rm -rf /var/cache/apk/*

COPY start.sh /

ENTRYPOINT ["/start.sh"]
CMD ["squid", "-N"]
