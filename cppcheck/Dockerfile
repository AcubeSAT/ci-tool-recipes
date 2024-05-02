FROM spacedot/build-base AS final

# BeautifulSoup to parse the cppcheck XML
RUN apt-get update && apt-get install --yes --no-install-recommends cppcheck libpcre3-dev tidy libxml2-utils
RUN pip install bs4 lxml pygments --break-system-packages
