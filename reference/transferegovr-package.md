# transferegovr: Access the 'TransfereGov' Open Data APIs

Provides a modern interface to the open data application programming
interfaces of the Brazilian federal government's 'TransfereGov' platform
(<https://www.gov.br/transferegov/pt-br/ferramentas-gestao/dados-abertos>).
Covers the special transfers, fund-to-fund transfers, and decentralized
credit ('TED') modules, which together publish forty-eight tables on
action plans, programs, budget commitments, financial execution,
management reports, and payment orders. The APIs are built on
'PostgREST', so the package exposes its filtering, column selection, and
ordering operators directly, and returns tidy tibbles with types taken
from the published schema. Automatic pagination, request throttling,
retries with exponential backoff, and an optional response cache are
included.

## See also

Useful links:

- <https://github.com/StrategicProjects/transferegovr>

- <https://strategicprojects.github.io/transferegovr/>

- Report bugs at
  <https://github.com/StrategicProjects/transferegovr/issues>

## Author

**Maintainer**: Andre Leite <leite@castlab.org>
([ORCID](https://orcid.org/0000-0002-4718-9766))

Authors:

- Andre Leite <leite@castlab.org>
  ([ORCID](https://orcid.org/0000-0002-4718-9766))

- Marcos Wasiliew <marcos.wasiliew@sepe.pe.gov.br>

- Hugo Vasconcelos <hugo.vasconcelos@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6249-0920))

- Carlos Amorim <carlos.agaf@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6315-8305))

- Diogo Bezerra <diogo.bezerra@ufpe.br>
  ([ORCID](https://orcid.org/0000-0002-1216-8674))

- Júlia Nascimento Barreto <juliabarreto@gd.seplag.pe.gov.br>
