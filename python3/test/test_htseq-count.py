import subprocess as sp

tests = [
    {'call': [
        'htseq-count',
        '-m', 'intersection-nonempty',
        '--nonunique', 'none',
        'example_data/yeast_RNASeq_excerpt_withNH.sam',
        'example_data/Saccharomyces_cerevisiae.SGD1.01.56.gtf.gz',
        ],
    'expected_fn': 'example_data/yeast_RNASeq_excerpt_withNH_counts.tsv'},
    {'call': [
        'htseq-count',
        '-m', 'intersection-nonempty',
        '--nonunique', 'all',
        'example_data/yeast_RNASeq_excerpt_withNH.sam',
        'example_data/Saccharomyces_cerevisiae.SGD1.01.56.gtf.gz',
        ],
    'expected_fn': 'example_data/yeast_RNASeq_excerpt_withNH_counts_nonunique.tsv'},
    {'call': [
        'htseq-count',
        '-m', 'intersection-nonempty',
        '-i', 'gene_id',
        '--additional-attr', 'gene_name',
        '--nonunique', 'none',
        'example_data/yeast_RNASeq_excerpt_withNH.sam',
        'example_data/yeast_RNASeq_excerpt_withNH.sam',
        'example_data/Saccharomyces_cerevisiae.SGD1.01.56.gtf.gz',
        ],
    'expected_fn': 'example_data/yeast_RNASeq_excerpt_withNH_counts_twocolumns.tsv'},
    ]


# Run the tests
for t in tests:
    expected_fn = t['expected_fn']
    call = t['call']
    # local testing
    #call = ['python', 'python3/HTSeq/scripts/count.py'] + call[1:]

    print(' '.join(call))
    output = sp.check_output(call).decode()

    with open(expected_fn, 'r') as f:
        expected = f.read()

    try:
        assert output == expected
    except AssertionError:
        for out, exp in zip(output.split('\n'), expected.split('\n')):
            print(out, exp)
            if out != exp:
                break

        raise
