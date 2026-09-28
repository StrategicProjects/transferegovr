# transferegovr: Access the 'TransfereGov' Open Data APIs

Provides a modern interface to the open data application programming
interfaces of the Brazilian federal government's 'TransfereGov' platform
(<https://www.gov.br/transferegov/pt-br/ferramentas-gestao/dados-abertos>).
Covers the special transfers, fund-to-fund transfers, partnership
management, and decentralized credit ('TED') modules, which together
publish seventy-four tables on action plans, programs, proposals,
partnerships, budget commitments, credit notes, financial execution,
management reports, and payment orders. Filters are the services' own
typed query parameters, validated against the published schema before a
request is made, and results are returned as tidy tibbles with types
taken from that schema. Automatic pagination, request throttling,
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

- Marcos Wasiliew <marcos.wasiliew@gmail.com>
  ([ORCID](https://orcid.org/0009-0004-4694-3159))

- Hugo Vasconcelos <hugo.vasconcelos@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6249-0920))

- Carlos Amorim <carlos.agaf@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6315-8305))

- Diogo Bezerra <diogo.bezerra@ufpe.br>
  ([ORCID](https://orcid.org/0000-0002-1216-8674))

- Júlia Nascimento Barreto <juliabarreto@gd.seplag.pe.gov.br>
  ([ORCID](https://orcid.org/0009-0004-2851-7770))
