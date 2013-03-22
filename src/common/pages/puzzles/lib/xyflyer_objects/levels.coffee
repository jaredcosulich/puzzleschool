levels = exports ? provide('./lib/xyflyer_objects/levels', {})

levels.STAGES = [
    {
        name: 'Simple Lines'
        levels: [
            {
                id: 1363227855683
                equations: 
                    '2x': {}
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                rings: [
                    {x: 1, y: 2}
                    {x: 3, y: 6}
                ]
                fragments: [
                    '2x'
                ]
            }
            {
                id: 1363227862789
                equations: 
                    'x+4': {start: 'x'}
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                rings: [
                    {x: -2, y: 2}
                    {x: 0, y: 4}
                    {x: 4, y: 8}
                ]
                islandCoordinates: {x: -6, y: -2}
                fragments: [
                    '+4', '-4'
                ]
            }
            {
                id: 1363227871084
                equations: 
                    'x-2': {start: 'x'}
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                rings: [
                    {x: 0, y: -2}
                    {x: 4, y: 2}
                    {x: 8, y: 6}
                ]
                islandCoordinates: {x: -4, y: -6}
                fragments: [
                    '+2', '-2', '+4', '-4'
                ]
            }
            {
                id: 1363227878373
                equations: 
                    '(1/4)*x': {start: 'x'}
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                rings: [
                    {x: 2, y: 0.5}
                    {x: 4, y: 1}
                    {x: 6, y: 1.5}
                ]
                fragments: [
                    '4*', '(1/4)*'
                ]
            }
            {
                id: 1363726126940
                equations:
                    '(1/5)*x':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/5)*', after: ''}
                        ]
                rings: [
                    {x: 5, y: 1}
                    {x: 10, y: 2}
                    {x: 15, y: 3}
                ]
                grid:
                    xMin: -20
                    xMax: 20
                    yMin: -20
                    yMax: 20
                islandCoordinates: {x: 0, y: 0}
                fragments: ['3*', '(1/3)*', '5*', '(1/5)*']
            }
            {
                id: 1363726028635
                equations:
                    '4*x':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '4*', after: ''}
                        ]
                rings: [
                    {x: 1, y: 4}
                    {x: 2, y: 8}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: 0, y: 0}
                fragments: ['2*', '(1/2)*', '4*', '(1/4)*']
            }
            {
                id: 1363889649942
                equations:
                    '-x-3':
                        start: '-x'
                        solutionComponents: [
                            {fragment: '-3', after: '-x'}
                        ]
                rings: [
                    {x: -4, y: 1}
                    {x: -1, y: -2}
                    {x: 2, y: -5}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -7, y: 4}
                fragments: ['+3', '+5', '-3', '-5']
            }
            {
                id: 1363898471122
                equations:
                    '-x+2':
                        start: '-x'
                        solutionComponents: [
                            {fragment: '+2', after: '-x'}
                        ]
                rings: [
                    {x: -2, y: 4}
                    {x: 1, y: 1}
                    {x: 4, y: -2}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -6, y: 8}
                fragments: ['+2', '-2', '+4', '-4']
            }
            {
                id: 1363899214658
                equations:
                    '(1/5)*-x':
                        start: '-x'
                        solutionComponents: [
                            {fragment: '(1/5)*', after: ''}
                        ]
                rings: [
                    {x: -10, y: 2}
                    {x: 5, y: -1}
                    {x: 20, y: -4}
                ]
                grid:
                    xMin: -25
                    xMax: 25
                    yMin: -25
                    yMax: 25
                islandCoordinates: {x: -20, y: 4}
                fragments: ['3*', '5*', '(1/3)*', '(1/5)*']
            }
        ]
    }
    {
        name: 'More Complex Lines'
        levels: [
            {
                id: 1363899729966
                equations:
                    '(1/3)*x+3':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/3)*', after: ''}
                            {fragment: '+3', after: 'x'}
                        ]
                rings: [
                    {x: -3, y: 2}
                    {x: 3, y: 4}
                    {x: 9, y: 6}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -6, y: 1}
                fragments: ['+3', '(1/3)*']
            }
            {
                id: 1363899946541
                equations:
                    '-2*x+5':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '-2*', after: ''}
                            {fragment: '+5', after: 'x'}
                        ]
                rings: [
                    {x: 1, y: 3}
                    {x: 3, y: -1}
                    {x: 5, y: -5}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -2, y: 9}
                fragments: ['2*', '-2*', '+5', '-5']
            }    
            {
                id: 1363229707272
                equations: 
                    '2*x+3': {start: 'x'}
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -5, y: -7}
                rings: [
                    {x: -2, y: -1}
                    {x: 0, y: 3}
                    {x: 2, y: 7}
                ]
                fragments: [
                    '2*', '(1/2)*', '+3', '-3'
                ]
            }
            {
                id: 1363727704223
                equations:
                    '(1/3)*x-2':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/3)*', after: ''}
                            {fragment: '-2', after: 'x'}
                        ]
                rings: [
                    {x: -3, y: -3}
                    {x: 3, y: -1}
                    {x: 9, y: 1}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -6, y: -4}
                fragments: ['3*', '(1/3)*', '-2', '+2']
            }
            {
                id: 1363727990375
                equations:
                    '3*x-12':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '3*', after: ''}
                            {fragment: '-12', after: 'x'}
                        ]
                rings: [
                    {x: 3, y: -3}
                    {x: 4, y: 0}
                    {x: 5, y: 3}
                ]
                grid:
                    xMin: -5
                    xMax: 15
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: 2, y: -6}
                fragments: ['3*', '(1/3)*', '+12', '-12']
            }
            {
                id: 1363367640281
                equations:
                    '(-1/2)*x+13':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(-1/2)*', after: ''}
                            {fragment: '+13', after: 'x'}
                        ]
                rings: [
                    {x: -6, y: 16}
                    {x: 6, y: 10}
                    {x: 18, y: 4}
                ]
                grid:
                    xMin: -30
                    xMax: 30
                    yMin: -30
                    yMax: 30
                islandCoordinates: {x: -18, y: 22}
                fragments: ['-2*', '(-1/2)*', '+13', '-13']
            }
            {
                id: 1363729451096
                equations:
                    '-4*x-32':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '-4*', after: ''}
                            {fragment: '-32', after: 'x'}
                        ]
                rings: [
                    {x: -5, y: -12}
                    {x: -6, y: -8}
                    {x: -4, y: -16}
                ]
                grid:
                    xMin: -17
                    xMax: 3
                    yMin: -17
                    yMax: 3
                islandCoordinates: {x: -7, y: -4}
                fragments: ['-4*', '(-1/4)*', '+32', '-32']
            }
            {
                id: 1363368153567
                equations:
                    '-1*5*x+32':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '-1*', after: ''}
                            {fragment: '5*', after: '-1*'}
                            {fragment: '+32', after: 'x'}
                        ]
                rings: [
                    {x: 4, y: 12}
                    {x: 7, y: -3}
                    {x: 10, y: -18}
                ]
                grid:
                    xMin: -5
                    xMax: 15
                    yMin: -30
                    yMax: 30
                islandCoordinates: {x: 1, y: 27}
                fragments: ['5*', '(1/5)*', '+32', '-32', '-1*']
            }
            {
                id: 1363392738634
                equations:
                    '(1/4)*x-3':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/4)*', after: ''}
                            {fragment: '-3', after: 'x'}
                        ]
                rings: [
                    {x: -2, y: -3.5}
                    {x: 2, y: -2.5}
                    {x: 6, y: -1.5}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -6, y: -4.5}
                fragments: ['4*', '(1/4)*', '+3', '-3', '*-1']
            }
        ]
    }
    {
        name: 'Variable Lines'
        levels: [
            {
                id: 1363229719931
                equations: 
                    'x+a': {start: 'x'}
                grid:
                    xMin: -20
                    xMax: 20
                    yMin: -20
                    yMax: 20
                rings: [
                    {x: -8, y: -2}
                    {x: 0, y: 6}
                    {x: 8, y: 14}
                ]
                islandCoordinates: {x: -16, y: -10}
                fragments: [
                    '+a', '-b'
                ]
                variables:
                    a:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 6
                    b:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
            }
            {
                id: 1363229739276
                equations: 
                    'x-b': {start: 'x'}
                grid:
                    xMin: -20
                    xMax: 20
                    yMin: -30
                    yMax: 10
                rings: [
                    {x: -8, y: -12}
                    {x: 0, y: -4}
                    {x: 8, y: 4}
                ]
                islandCoordinates: {x: -16, y: -20}
                fragments: [
                    '+a', '-b'
                ]
                variables:
                    a:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                    b:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 4
            }
            {
                id: 1363229750440
                equations: 
                    '-x-b': {start: '-x'}
                grid:
                    xMin: -20
                    xMax: 20
                    yMin: -20
                    yMax: 20
                rings: [
                    {x: -8, y: 0}
                    {x: 0, y: -8}
                    {x: 8, y: -16}
                ]
                islandCoordinates: {x: -16, y: 8}
                fragments: [
                    '+a', '-b'
                ]
                variables:
                    a:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                    b:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 8
            }
            {
                id: 1363229759840
                equations: 
                    '-x-b': {start: '-x'}
                grid:
                    xMin: -5
                    xMax: 35
                    yMin: -35
                    yMax: 5
                rings: [
                    {x: 10, y: -15}
                    {x: 15, y: -20}
                    {x: 20, y: -25}
                ]
                islandCoordinates: {x: 0, y: -5}
                fragments: [
                    '+a', '-b'
                ]
                variables:
                    a:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                    b:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 5
            }
            {
                id: 1363229798825
                equations: 
                    'ax+12': {start: 'ax+12'}
                grid:
                    xMin: -40
                    xMax: 60
                    yMin: -60
                    yMax: 40
                rings: [
                    {x: 5, y: -13}
                    {x: 10, y: -38}
                    {x: 12, y: -48}
                ]
                islandCoordinates: {x: 0, y: 12}
                variables:
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: -5
            }    
            {
                id: 1363229806832
                equations: 
                    '(1/b)x+c': {start: 'x'}
                grid:
                    xMin: -20
                    xMax: 20
                    yMin: -10
                    yMax: 10
                rings: [
                    {x: -5, y: 2}
                    {x: 5, y: 4}
                    {x: 15, y: 6}
                ]
                islandCoordinates: {x: -15, y: 0}
                fragments: [
                    'a*', '(1/b)', '+c', '-d'
                ]
                variables:
                    a:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                    b:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 5        
                    c:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 3       
                    d:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
            }
            {
                id: 1363229814257
                equations: 
                    'a*x+c': {start: 'x'}
                grid:
                    xMin: -20
                    xMax: 20
                    yMin: -50
                    yMax: 50
                rings: [
                    {x: -5, y: -9}
                    {x: 5, y: 21}
                    {x: 12, y: 42}
                ]
                islandCoordinates: {x: -12, y: -30}
                fragments: [
                    'a*', '(1/b)', '+c', '-d'
                ]
                variables:
                    a:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 3
                    b:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                    c:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 6       
                    d:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
            }
            {
                id: 1363229822498
                equations: 
                    'x-d': {start: 'x'}
                grid:
                    xMin: -20
                    xMax: 20
                    yMin: -20
                    yMax: 20
                rings: [
                    {x: -5, y: -10}
                    {x: 5, y: 0}
                    {x: 10, y: 5}
                ]
                islandCoordinates: {x: -10, y: -15}
                fragments: [
                    'a*', '(1/b)', '+c', '-d'
                ]
                variables:
                    a:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                    b:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                    c:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                    d:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 5
            }
            {
                id: 1363902958905
                equations:
                    '(1/b)*x-d':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/b)*', after: ''}
                            {fragment: '-d', after: 'x'}
                        ]
                rings: [
                    {x: -3, y: -4}
                    {x: 3, y: -6}
                    {x: 9, y: -8}
                ]
                grid:
                    xMin: -15
                    xMax: 15
                    yMin: -20
                    yMax: 5
                islandCoordinates: {x: -9, y: -2}
                fragments: ['a*', '(1/b)*', '+c', '-d']
                variables: 
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: null
                    b:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: -3
                    c:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: null
                    d:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 5
            }
        ]
    }
    {
        name: 'Multiple Lines'
        levels: [
            {
                id: 1363229830265
                equations:
                    '-x-c': {start: '-x'}
                    'x-d': {start: 'x'}
                grid:
                    xMin: -20
                    xMax: 20
                    yMin: -20
                    yMax: 20
                rings: [
                    {x: -5, y: -5}
                    {x: 5, y: -5}
                    {x: 15, y: 5}
                ]
                fragments: [
                    '+a', '+b', '-c', '-d'
                ]
                islandCoordinates: {x: -15, y: 5}
                variables:
                    a:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                    b:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1  
                    c:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1  
                        solution: 10
                    d:
                        start: 1
                        min: 0
                        max: 10
                        increment: 1
                        solution: 10  
            }        
            {
                id: 1363229838153
                equations:
                    '2x': {}
                    '(1/2)x+2': {}
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                rings: [
                    {x: .5, y: 1}
                    {x: 6, y: 5}
                ]
                fragments: [
                    '2x', '(1/2)x', '+2'
                ]
            }    
            {
                id: 1363382168264
                equations:
                    'a*x':
                        start: 'x'
                        solutionComponents: [
                            {fragment: 'a*', after: ''}
                        ]
                    'b*x':
                        start: 'x'
                        solutionComponents: [
                            {fragment: 'b*', after: ''}
                        ]
                rings: [
                    {x: -10, y: -20}
                    {x: -5, y: -10}
                    {x: 5, y: -10}
                    {x: 10, y: -20}
                ]
                grid:
                    xMin: -50
                    xMax: 50
                    yMin: -50
                    yMax: 50
                islandCoordinates: {x: -16, y: -32}
                fragments: ['a*', 'b*', '(1/c)*', '(1/d)*']
                variables: 
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: -2
                    b:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: 2
                    c:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: null
                    d:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: null
            }
            {
                id: 1363372189102
                equations:
                    'a*x-5':
                        start: 'x'
                        solutionComponents: [
                            {fragment: 'a*', after: ''}
                            {fragment: '-5', after: 'x'}
                        ]
                    '(1/b)*x+12':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/b)*', after: ''}
                            {fragment: '+12', after: 'x'}
                        ]
                rings: [
                    {x: -1, y: -10}
                    {x: 3, y: 10}
                    {x: 24, y: 15}
                ]
                grid:
                    xMin: -15
                    xMax: 45
                    yMin: -30
                    yMax: 30
                islandCoordinates: {x: -3, y: -20}
                fragments: ['a*', '(1/b)*', '-5', '+12']
                variables: 
                    a:
                        start: 1
                        min: 1
                        max: 10
                        increment: 1
                        solution: 5
                    b:
                        start: 1
                        min: 1
                        max: 10
                        increment: 1
                        solution: 8
            }
            {
                id: 1363625636226
                equations:
                    '(1/a)*x+c':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/a)*', after: ''}
                            {fragment: '+c', after: 'x'}
                        ]
                    '(1/b)*x+d':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/b)*', after: ''}
                            {fragment: '+d', after: 'x'}
                        ]
                rings: [
                    {x: -1, y: 2.25}
                    {x: 2, y: 1.5}
                    {x: 5, y: 0.75}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -6, y: 2}
                fragments: ['(1/a)*', '(1/b)*', '+c', '+d']
                variables: 
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: 6
                    b:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: -4
                    c:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: 3
                    d:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: 2
            }
            {
                id: 1363446018764
                equations:
                    '(1/b)x-6':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/b)', after: ''}
                            {fragment: '-6', after: 'x'}
                        ]
                    'a*x-20':
                        start: 'x'
                        solutionComponents: [
                            {fragment: 'a*', after: ''}
                            {fragment: '-20', after: 'x'}
                        ]
                rings: [
                    {x: -8, y: -4}
                    {x: 5, y: -5}
                    {x: 10, y: 10}
                ]
                grid:
                    xMin: -25
                    xMax: 25
                    yMin: -25
                    yMax: 25
                islandCoordinates: {x: -20, y: -1}
                fragments: ['(1/b)', 'a*', '-20', '-6']
                variables: 
                    b:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: -4
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: 3
            }
            {
                id: 1363623610571
                equations:
                    '(1/8)*x+b':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/8)*', after: ''}
                            {fragment: '+b', after: 'x'}
                        ]
                    '(1/a)*x-5':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/a)*', after: ''}
                            {fragment: '-5', after: 'x'}
                        ]
                rings: [
                    {x: 2, y: -4}
                    {x: 4, y: -3}
                    {x: 6, y: -2}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -4, y: -6.5}
                fragments: ['(1/a)*', '(1/8)*', '+b', '-5']
                variables: 
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: 2
                    b:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: -6
            }
            {
                id: 1363229845866
                equations:
                    'a*x+c':
                        start: 'x'
                        solutionComponents: [
                            {fragment:'a*', after:''},
                            {fragment:'+c', after:'x'}
                        ]
                    '(1/b)*x+d':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/b)*', after: ''},
                            {fragment: '+d', after: 'x'}
                        ]
                rings:[
                    {x:-4,y:2},
                    {x:-2,y:-4},
                    {x:5,y:-5}
                ]
                grid:
                    xMin:-10
                    xMax:10
                    yMin:-10
                    yMax:10
                islandCoordinates: {x:-6,y:8}
                fragments: ["a*","(1/b)*","+c","+d"]
                variables:
                    "a":{"start":1,"min":-10,"max":10,"increment":1,"solution":"-3"}
                    "b":{"start":1,"min":-10,"max":10,"increment":1,"solution":"5"}
                    "c":{"start":1,"min":-10,"max":10,"increment":1,"solution":"-10"}
                    "d":{"start":1,"min":-10,"max":10,"increment":1,"solution":"-6"}
            }                                
        ]
    }
    {
        name: 'Lines and Curves'
        levels: [
            {
                id: 1363640447671
                equations:
                    '(x)^2-6':
                        start: '(x)^2'
                        solutionComponents: [
                            {fragment: '-6', after: '(x)^2'}
                        ]
                    '(1/4)*x':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/4)*', after: ''}
                        ]
                rings: [
                    {x: 2, y: -2}
                    {x: -2, y: -2}
                    {x: -4, y: -1}
                    {x: 4, y: 1}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -6.552, y: -1.588}
                fragments: ['(1/4)*', '-6']
            }
            {
                id: 1363642523297
                equations:
                    '(x+a)^2':
                        start: '(x)^2'
                        solutionComponents: [
                            {fragment: '+a', after: 'x'}
                        ]
                    '0':
                        solutionComponents: [
                            {fragment: '0', after: ''}
                        ]
                rings: [
                    {x: 5, y: 1}
                    {x: 6, y: 4}
                    {x: 7, y: 9}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: 0, y: 0}
                fragments: ['+a', '0']
                variables: 
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: -4
            }
            {
                id: 1363643301742
                equations:
                    '(x+a)^2-2':
                        start: '(x)^2'
                        solutionComponents: [
                            {fragment: '+a', after: 'x'}
                            {fragment: '-2', after: '(x+a)^2'}
                        ]
                    '-2':
                        solutionComponents: [
                            {fragment: '-2', after: ''}
                        ]
                rings: [
                    {x: 3, y: -1}
                    {x: 4, y: 2}
                    {x: 5, y: 7}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -6, y: -2}
                fragments: ['+a', '-2', '-2']
                variables: 
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: -2
            }
            {
                id: 1363645001878
                equations:
                    '(1/2)*x+6':
                        start: 'x'
                        solutionComponents: [
                            {fragment: '(1/2)*', after: ''}
                            {fragment: '+6', after: 'x'}
                        ]
                    '((1/4)*x)^2':
                        start: '(x)^2'
                        solutionComponents: [
                            {fragment: '(1/4)*', after: '('}
                        ]
                rings: [
                    {x: -4, y: 1}
                    {x: 4, y: 1}
                    {x: 12, y: 9}
                ]
                grid:
                    xMin: -15
                    xMax: 15
                    yMin: -15
                    yMax: 15
                islandCoordinates: {x: -12, y: 0}
                fragments: ['(1/4)*', '(1/2)*', '+6']
            }
            {
                id: 1363230030642
                equations:
                    '((1/3)*x)^2-32': {start: '(x)^2'}
                    '(1/6)*x+20': {start: 'x'}
                grid:
                    xMin: -50
                    xMax: 50
                    yMin: -50
                    yMax: 50
                rings: [
                    {x: -9, y: -23}
                    {x: 12, y: -16}
                    {x: 36, y: 26}
                ]
                fragments: [
                    '(1/3)*', '(1/6)*', '-32', '+20'
                ]
                islandCoordinates: {x: -18, y: 4}
                variables:
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: -4
                    b:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1  
                        solution: -5      
            }    
        ]
    }
    {
        name: 'Multiple Curves'
        levels: [
            {
                id: 1363646545338
                equations:
                    '(1/4)*(x)^2-3':
                        start: '(x)^2'
                        solutionComponents: [
                            {fragment: '(1/4)*', after: ''}
                            {fragment: '-3', after: '(x)^2'}
                        ]
                    '((1/4)*x)^2':
                        start: '(x)^2'
                        solutionComponents: [
                            {fragment: '(1/4)*', after: '('}
                        ]
                rings: [
                    {x: -6, y: 6}
                    {x: 6, y: 6}
                    {x: 0, y: 0}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -5
                    yMax: 15
                islandCoordinates: {x: -8, y: 13}
                fragments: ['(1/4)*', '(1/4)*', '-3']
            }
        ]
    }
    {
        name: 'Crazy Curves'
        levels: [
            {
                id: 1363927709647
                equations:
                    'sin(a*x)+5':
                        solutionComponents: [
                            {fragment: 'sin(x)', after: ''}
                            {fragment: 'a*', after: 'sin('}
                            {fragment: '+5', after: 'sin(a*x)'}
                        ]
                rings: [
                    {x: 0.52, y: 6}
                    {x: 3.67, y: 4}
                    {x: 4.71, y: 6}
                    {x: 1.57, y: 4}
                ]
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                islandCoordinates: {x: -2.62, y: 4}
                fragments: ['sin(x)', 'a*', '+5']
                variables: 
                    a:
                        start: 1
                        min: -10
                        max: 10
                        increment: 1
                        solution: 3
            }
        ]
    }
]


