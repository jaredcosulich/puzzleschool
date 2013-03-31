levels = exports ? provide('./lib/xyflyer_objects/levels', {})

levels.WORLDS = [
    {
        stages: [
            {
                name: 'Shifting Lines'
                levels: [
                    {
                        id: 1364229884455
                        equations:
                            'x+4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+4', after: 'x'}
                                ]
                        rings: [
                            {x: -4, y: 0}
                            {x: 0, y: 4}
                            {x: 4, y: 8}
                        ]
                        grid:
                            xMin: -15
                            xMax: 15
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -8, y: -4}
                        fragments: ['+4']
                    }
                    {
                        id: 1364577895069
                        equations:
                            'x+8':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+8', after: 'x'}
                                ]
                        fragments: ['+8', '-8']
                        rings: [
                            {x: -8, y: 0}
                            {x: -4, y: 4}
                            {x: 0, y: 8}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: -12, y: -4}
                    }
                    {
                        id: 1364578077315
                        equations:
                            'x+3':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+3', after: 'x'}
                                ]
                        fragments: ['+3', '-3']
                        rings: [
                            {x: -3, y: 0}
                            {x: 0, y: 3}
                            {x: 3, y: 6}
                        ]
                        grid:
                            xMin: -15
                            xMax: 15
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -6, y: -3}
                    }
                    {
                        id: 1364230317228
                        equations:
                            'x-5':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-5', after: 'x'}
                                ]
                        rings: [
                            {x: 0, y: -5}
                            {x: 5, y: 0}
                            {x: 10, y: 5}
                        ]
                        grid:
                            xMin: -25
                            xMax: 25
                            yMin: -25
                            yMax: 25
                        islandCoordinates: {x: -5, y: -10}
                        fragments: ['+5', '-5']
                    }
                    {
                        id: 1364225130330
                        equations:
                            'x-4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-4', after: 'x'}
                                ]
                        rings: [
                            {x: 4, y: 0}
                            {x: 6, y: 2}
                            {x: 8, y: 4}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: 2, y: -2}
                        fragments: ['+4', '-4']
                    }
                    {
                        id: 1364578660117
                        equations:
                            'x+20':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-20', after: 'x'}
                                ]
                        fragments: ['+20', '-20']
                        rings: [
                            {x: -20, y: 0}
                            {x: -10, y: 10}
                            {x: 0, y: 20}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -30, y: -10}
                    }
                    {
                        id: 1364579016552
                        equations:
                            'x+6':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+6', after: 'x'}
                                ]
                        fragments: ['+3', '-3', '+6', '-6']
                        rings: [
                            {x: -6, y: 0}
                            {x: 0, y: 6}
                            {x: 6, y: 12}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -12, y: -6}
                    }
                    {
                        id: 1364580124694
                        equations:
                            'x-6':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-6', after: 'x'}
                                ]
                        fragments: ['+6', '-6', '+9', '-9']
                        rings: [
                            {x: 0, y: -6}
                            {x: 6, y: 0}
                            {x: 12, y: 6}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -6, y: -12}
                    }
                    {
                        id: 1364580310767
                        equations:
                            'x-18':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-18', after: 'x'}
                                ]
                        fragments: ['+9', '-9', '+18', '-18']
                        rings: [
                            {x: 0, y: -18}
                            {x: 18, y: 0}
                            {x: 30, y: 12}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -12, y: -30}
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
                            {x: -3, y: 0}
                            {x: 0, y: -3}
                            {x: 3, y: -6}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -6, y: 3}
                        fragments: ['+3', '-3']
                    }
                    {
                        id: 1364580586738
                        equations:
                            '-x-20':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-20', after: '-x'}
                                ]
                        fragments: ['+20', '-20']
                        rings: [
                            {x: -20, y: 0}
                            {x: 0, y: -20}
                            {x: 20, y: -40}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -40, y: 20}
                    }
                    {
                        id: 1364581109101
                        equations:
                            '-x-1':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-3', after: '-x'}
                                ]
                        fragments: ['+1', '-1', '+4', '-4']
                        rings: [
                            {x: -1, y: 0}
                            {x: 0, y: -1}
                            {x: 3, y: -4}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -4, y: 3}
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
                            {x: -3, y: 5}
                            {x: 0, y: 2}
                            {x: 2, y: 0}
                            {x: 5, y: -3}
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
                        id: 1364581756908
                        equations:
                            '-x+7':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+7', after: '-x'}
                                ]
                        fragments: ['+7', '-7', '+14', '-14']
                        rings: [
                            {x: 0, y: 7}
                            {x: 7, y: 0}
                            {x: 14, y: -7}
                        ]
                        grid:
                            xMin: -17
                            xMax: 17
                            yMin: -17
                            yMax: 17
                        islandCoordinates: {x: -7, y: 14}
                    }                    
                    {
                        id: 1364225219109
                        equations:
                            'x+2':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+2', after: 'x'}
                                ]
                        rings: [
                            {x: -2, y: 0}
                            {x: 0, y: 2}
                            {x: 2, y: 4}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -4, y: -2}
                        fragments: ['+2', '+5', '-2', '-5']
                    }
                    {
                        id: 1364231736746
                        equations:
                            '-x+18':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+18', after: '-x'}
                                ]
                        rings: [
                            {x: 0, y: 18}
                            {x: 9, y: 9}
                            {x: 18, y: 0}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -9, y: 27}
                        fragments: ['+8', '-8', '+18', '-18']
                    }
                    {
                        id: 1364232064737
                        equations:
                            '-x-5':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-5', after: '-x'}
                                ]
                        rings: [
                            {x: -5, y: 0}
                            {x: 0, y: -5}
                            {x: 5, y: -10}
                        ]
                        grid:
                            xMin: -15
                            xMax: 15
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -10, y: 5}
                        fragments: ['+3', '-3', '+5', '-5']
                    }
                    {
                        id: 1364231355522
                        equations:
                            '-x+21-7':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+21', after: '-x'}
                                    {fragment: '-7', after: '+21'}
                                ]
                        rings: [
                            {x: -14, y: 28}
                            {x: 0, y: 14}
                            {x: 14, y: 0}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -28, y: 42}
                        fragments: ['+7', '-7', '+21', '-21']
                    }
                    {
                        id: 1364235830450
                        equations:
                            'x+2-5':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+2', after: 'x'}
                                    {fragment: '-5', after: '+2'}
                                ]
                        rings: [
                            {x: 0, y: -3}
                            {x: 3, y: 0}
                            {x: 6, y: 3}
                        ]
                        grid:
                            xMin: -15
                            xMax: 15
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -3, y: -6}
                        fragments: ['+2', '-2', '+5', '-5']
                    }
                    {
                        id: 1364236569983
                        equations:
                            '-x-25+35':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-25', after: '-x'}
                                    {fragment: '+35', after: '-25'}
                                ]
                        rings: [
                            {x: -10, y: 20}
                            {x: 0, y: 10}
                            {x: 10, y: 0}
                        ]
                        grid:
                            xMin: -35
                            xMax: 35
                            yMin: -35
                            yMax: 35
                        islandCoordinates: {x: -20, y: 30}
                        fragments: ['+25', '-25', '+35', '-35']
                    }
            
                ]
            }
            {
                name: 'Changing Slope'
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
                            '2x', '(1/2)x'
                        ]
                    }
                    {
                        id: 1364599564266
                        equations:
                            '5*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '5*', after: ''}
                                ]
                        fragments: ['5*', '(1/5)*']
                        rings: [
                            {x: -1, y: -5}
                            {x: 1, y: 5}
                            {x: 3, y: 15}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -3, y: -15}
                    }
                    {
                        id: 1364599999113
                        equations:
                            '3*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '3*', after: ''}
                                ]
                        fragments: ['3*', '(1/3)*']
                        rings: [
                            {x: 1, y: 3}
                            {x: 0, y: 0}
                            {x: 2, y: 6}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -1, y: -3}
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
                        fragments: ['5*', '(1/5)*']
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
                        fragments: ['4*', '(1/4)*']
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
                        fragments: ['5*', '(1/5)*']
                    }
                    {
                        id: 1364317431321
                        equations:
                            '(1/3)*-x':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '(1/3)*', after: ''}
                                ]
                        rings: [
                            {x: -3, y: 1}
                            {x: 3, y: -1}
                            {x: 6, y: -2}
                            {x: 0, y: 0}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -6, y: 2}
                        fragments: ['3*', '(1/3)*']
                    }
                    {
                        id: 1364320352722
                        equations:
                            '2*-x':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '2*', after: ''}
                                ]
                        rings: [
                            {x: -2, y: 4}
                            {x: 0, y: 0}
                            {x: 2, y: -4}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -4, y: 8}
                        fragments: ['2*', '(1/2)*']
                    }
                    {
                        id: 1364603649394
                        equations:
                            '4*-x':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '4*', after: ''}
                                ]
                        fragments: ['4*', '(1/4)*']
                        rings: [
                            {x: -1, y: 4}
                            {x: 0, y: 0}
                            {x: 1, y: -4}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -2, y: 8}
                    }
                    {
                        id: 1364318896882
                        equations:
                            '-5*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-5*', after: ''}
                                ]
                        rings: [
                            {x: -1, y: 5}
                            {x: 1, y: -5}
                            {x: 3, y: -15}
                        ]
                        grid:
                            xMin: -25
                            xMax: 25
                            yMin: -25
                            yMax: 25
                        islandCoordinates: {x: -3, y: 15}
                        fragments: ['5*', '-5*']
                    }
                    {
                        id: 1364320805441
                        equations:
                            '6*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '6*', after: ''}
                                ]
                        rings: [
                            {x: -1, y: -6}
                            {x: 2, y: 12}
                            {x: 5, y: 30}
                        ]
                        grid:
                            xMin: -40
                            xMax: 40
                            yMin: -40
                            yMax: 40
                        islandCoordinates: {x: -4, y: -24}
                        fragments: ['6*', '-6*']
                    }
                    {
                        id: 1364321553399
                        equations:
                            '(1/5)*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/5)*', after: ''}
                                ]
                        rings: [
                            {x: -5, y: -1}
                            {x: 5, y: 1}
                            {x: 15, y: 3}
                        ]
                        grid:
                            xMin: -25
                            xMax: 25
                            yMin: -25
                            yMax: 25
                        islandCoordinates: {x: -15, y: -3}
                        fragments: ['(1/5)*', '(-1/5)*']
                    }
                    {
                        id: 1364321105883
                        equations:
                            '(-1/3)*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(-1/3)*', after: ''}
                                ]
                        rings: [
                            {x: -6, y: 2}
                            {x: 3, y: -1}
                            {x: 12, y: -4}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: -15, y: 5}
                        fragments: ['(1/3)*', '(-1/3)*']
                    }
                    {
                        id: 1364321710361
                        equations:
                            '-2*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-2*', after: ''}
                                ]
                        rings: [
                            {x: -1, y: 2}
                            {x: 1, y: -2}
                            {x: 3, y: -6}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -3, y: 6}
                        fragments: ['2*', '-2*', '(1/2)*', '(-1/2)*']
                    }            
                    {
                        id: 1364323332127
                        equations:
                            '(1/4)*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/4)*', after: ''}
                                ]
                        rings: [
                            {x: -4, y: -1}
                            {x: 4, y: 1}
                            {x: 12, y: 3}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: -12, y: -3}
                        fragments: ['4*', '(1/4)*', '-4*', '(-1/4)*']
                    }
                    {
                        id: 1364604226181
                        equations:
                            '(-1/5)*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(-1/5)*', after: ''}
                                ]
                        fragments: ['5*', '-5*', '(1/5)*', '(-1/5)*']
                        rings: [
                            {x: -5, y: 1}
                            {x: 0, y: 0}
                            {x: 5, y: -1}
                        ]
                        grid:
                            xMin: -15
                            xMax: 15
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -10, y: 2}
                    }
                    {
                        id: 1364324406984
                        equations:
                            '(1/2)*6*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/2)*', after: ''}
                                    {fragment: '6*', after: '(1/2)*'}
                                ]
                        rings: [
                            {x: -1, y: -3}
                            {x: 3, y: 9}
                            {x: 7, y: 21}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -5, y: -15}
                        fragments: ['2*', '(1/2)*', '6*', '(1/6)*']
                    }
                    {
                        id: 1364324629711
                        equations:
                            '2*3*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '2*', after: ''}
                                    {fragment: '3*', after: '2*'}
                                ]
                        rings: [
                            {x: -1, y: -6}
                            {x: 1, y: 6}
                            {x: 3, y: 18}
                        ]
                        grid:
                            xMin: -36
                            xMax: 36
                            yMin: -36
                            yMax: 36
                        islandCoordinates: {x: -3, y: -18}
                        fragments: ['2*', '3*', '(1/2)*', '(1/3)*']
                    }
                    {
                        id: 1364324786570
                        equations:
                            '3*(-1/3)*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '3*', after: ''}
                                    {fragment: '(-1/3)*', after: '3*'}
                                ]
                        rings: [
                            {x: -4, y: 4}
                            {x: 2, y: -2}
                            {x: 8, y: -8}
                        ]
                        grid:
                            xMin: -15
                            xMax: 15
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -10, y: 10}
                        fragments: ['3*', '(1/3)*', '-3*', '(-1/3)*']
                    }
                ]
            }
        ]
    }
    {
        stages : [
            {
                name: 'Shift And Slope'
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
                        id: 1363229707272
                        equations: 
                            '2*x+3': {start: 'x'}
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
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
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
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
                            xMin: -10
                            xMax: 20
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: 2, y: -6}
                        fragments: ['3*', '(1/3)*', '+12', '-12']
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
                        id: 1364605842905
                        equations:
                            '(-1/3)*x+8':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(-1/3)*', after: ''}
                                    {fragment: '+8', after: 'x'}
                                ]
                        fragments: ['(1/3)*', '(-1/3)*', '+8', '-8']
                        rings: [
                            {x: 0, y: 8}
                            {x: 24, y: 0}
                            {x: 12, y: 4}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -12, y: 12}
                    }
                    {
                        id: 1364606006532
                        equations:
                            '(1/4)*x+6':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/4)*', after: ''}
                                    {fragment: '+6', after: 'x'}
                                ]
                        fragments: ['(1/4)*', '(-1/4)*', '+6', '-6']
                        rings: [
                            {x: -24, y: 0}
                            {x: 0, y: 6}
                            {x: 24, y: 12}
                        ]
                        grid:
                            xMin: -60
                            xMax: 60
                            yMin: -60
                            yMax: 60
                        islandCoordinates: {x: -48, y: -6}
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
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -6, y: -4.5}
                        fragments: ['4*', '(1/4)*', '+3', '-3', '*-1']
                    }
                    {
                        id: 1364337931784
                        equations:
                            '(1/4)*x+15':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/4)*', after: ''}
                                    {fragment: '+15', after: 'x'}
                                ]
                        rings: [
                            {x: -4, y: 14}
                            {x: 8, y: 17}
                            {x: 20, y: 20}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -16, y: 11}
                        fragments: ['4*', '(1/4)*', '+15', '-15']
                    }
                    {
                        id: 1364338302356
                        equations:
                            '-1*5*x-100':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-1*', after: ''}
                                    {fragment: '5*', after: '-1*'}
                                    {fragment: '-100', after: 'x'}
                                ]
                        rings: [
                            {x: -24, y: 20}
                            {x: -20, y: 0}
                            {x: -16, y: -20}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -28, y: 40}
                        fragments: ['5*', '(1/5)*', '+100', '-100', '-1*']
                    }            
                    {
                        id: 1364334055997
                        equations:
                            '-1*(1/3)*x+12':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-1*', after: ''}
                                    {fragment: '(1/3)*', after: '-1*'}
                                    {fragment: '+12', after: 'x'}
                                ]
                        rings: [
                            {x: -9, y: 15}
                            {x: 3, y: 11}
                            {x: 15, y: 7}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -21, y: 19}
                        fragments: ['3*', '(1/3)*', '+12', '-12', '-1*']
                    }
                    {
                        id: 1364335290588
                        equations:
                            '-1*(1/4)*x-7':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-1*', after: ''}
                                    {fragment: '(1/4)*', after: '-1*'}
                                    {fragment: '-7', after: 'x'}
                                ]
                        rings: [
                            {x: -4, y: -6}
                            {x: 4, y: -8}
                            {x: 12, y: -10}
                        ]
                        grid:
                            xMin: -21
                            xMax: 21
                            yMin: -35
                            yMax: 7
                        islandCoordinates: {x: -12, y: -4}
                        fragments: ['4*', '(1/4)*', '+7', '-7', '-1*']
                    }
                    {
                        id: 1364335789666
                        equations:
                            '3*x+3+4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '3*', after: ''}
                                    {fragment: '+3', after: 'x'}
                                    {fragment: '+4', after: '+3'}
                                ]
                        rings: [
                            {x: -2, y: 1}
                            {x: -1, y: 4}
                            {x: 0, y: 7}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -3, y: -2}
                        fragments: ['3*', '4*', '+3', '+4']
                    }
                    {
                        id: 1364336010759
                        equations:
                            'x*2+2*4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '*2', after: 'x'}
                                    {fragment: '+2', after: '*2'}
                                    {fragment: '*4', after: '+2'}
                                ]
                        rings: [
                            {x: -4, y: 0}
                            {x: 0, y: 8}
                            {x: 4, y: 16}
                        ]
                        grid:
                            xMin: -24
                            xMax: 24
                            yMin: -24
                            yMax: 24
                        islandCoordinates: {x: -8, y: -8}
                        fragments: ['*2', '*4', '+2', '+4']
                    }
                    {
                        id: 1364339817678
                        equations:
                            '6*(1/3)*x-2':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '6*', after: ''}
                                    {fragment: '(1/3)*', after: ''}
                                    {fragment: '-2', after: ''}
                                ]
                        rings: [
                            {x: -1, y: -4}
                            {x: 2, y: 2}
                            {x: 5, y: 8}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: -4, y: -10}
                        fragments: ['-1*', '6*', '(1/3)*', '+5', '-2']
                    }
                    {
                        id: 1364340176597
                        equations:
                            '-1*4*x+10+15':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-1*', after: ''}
                                    {fragment: '4*', after: '-1*'}
                                    {fragment: '+10', after: 'x'}
                                    {fragment: '+15', after: '+10'}
                                ]
                        rings: [
                            {x: 5, y: 5}
                            {x: 6, y: 1}
                            {x: 7, y: -3}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: 4, y: 9}
                        fragments: ['-1*', '4*', '(1/2)*', '+10', '+15']
                    }
                    {
                        id: 1364337246109
                        equations:
                            'x*-1*2+8*(1/2)':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '*-1', after: 'x'}
                                    {fragment: '*2', after: '*-1'}
                                    {fragment: '+8', after: '*2'}
                                    {fragment: '*(1/2)', after: '+8'}
                                ]
                        rings: [
                            {x: 0, y: 4}
                            {x: 2, y: 0}
                            {x: 4, y: -4}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -2, y: 8}
                        fragments: ['*-1', '*(1/2)', '*2', '+8']
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
                            xMin: -25
                            xMax: 25
                            yMin: -25
                            yMax: 25
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
                        islandCoordinates: {x: 5, y: -10}
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
                            {x: 4, y: -8}
                            {x: 8, y: -28}
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
                        id: 1364407089585
                        equations:
                            '(1/b)*x-5':
                                start: 'x-5'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                ]
                        rings: [
                            {x: -6, y: -3}
                            {x: 6, y: -7}
                            {x: 18, y: -11}
                        ]
                        grid:
                            xMin: -25
                            xMax: 25
                            yMin: -25
                            yMax: 25
                        islandCoordinates: {x: -18, y: 1}
                        fragments: ['a*', '(1/b)*']
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
                    }
                    {
                        id: 1364407581877
                        equations:
                            'a*x+3':
                                start: 'x+3'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                ]
                        rings: [
                            {x: -2, y: -5}
                            {x: 2, y: 11}
                            {x: 6, y: 27}
                        ]
                        grid:
                            xMin: -40
                            xMax: 40
                            yMin: -40
                            yMax: 40
                        islandCoordinates: {x: -6, y: -21}
                        fragments: ['a*', '(1/b)*']
                        variables: 
                            a:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: 4
                            b:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: null
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
                            xMin: -50
                            xMax: 50
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
                            xMin: -40
                            xMax: 40
                            yMin: -40
                            yMax: 40
                        rings: [
                            {x: -5, y: -10}
                            {x: 5, y: 0}
                            {x: 15, y: 10}
                        ]
                        islandCoordinates: {x: -15, y: -20}
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
                    {
                        id: 1364411932551
                        equations:
                            '(1/b)*x+c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                    {fragment: '+c', after: 'x'}
                                ]
                        rings: [
                            {x: -4, y: 7}
                            {x: 8, y: 10}
                            {x: 20, y: 13}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -16, y: 4}
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
                                solution: 4
                            c:
                                start: 1
                                min: 0
                                max: 10
                                increment: 1
                                solution: 8
                            d:
                                start: 1
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                    }
                    {
                        id: 1364413059940
                        equations:
                            'a*x+c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                    {fragment: '+c', after: 'x'}
                                ]
                        rings: [
                            {x: 12, y: 18}
                            {x: 16, y: -6}
                            {x: 20, y: -30}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: 8, y: 42}
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        variables: 
                            a:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: -6
                            b:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 100
                                increment: 10
                                solution: 90
                            d:
                                start: 0
                                min: 0
                                max: 100
                                increment: 10
                                solution: null
                    }
                    {
                        id: 1364417297857
                        equations:
                            'a*x-d':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                    {fragment: '-d', after: 'x'}
                                ]
                        rings: [
                            {x: -24, y: 12}
                            {x: -16, y: -12}
                            {x: -8, y: -36}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -32, y: 36}
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        variables: 
                            a:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: -3
                            b:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 100
                                increment: 10
                                solution: null
                            d:
                                start: 0
                                min: 0
                                max: 100
                                increment: 10
                                solution: 60
                    }
                    {
                        id: 1364417558374
                        equations:
                            '(1/b)*x-d':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                    {fragment: '-d', after: 'x'}
                                ]
                        rings: [
                            {x: -3, y: -4.5}
                            {x: 6, y: -3}
                            {x: 15, y: -1.5}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: -12, y: -6}
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
                                solution: 6
                            c:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            d:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                    }
                    {
                        id: 1364417830593
                        equations:
                            'a*x+c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                    {fragment: '+c', after: 'x'}
                                ]
                        rings: [
                            {x: 5, y: 25}
                            {x: 20, y: 10}
                            {x: 35, y: -5}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -10, y: 40}
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        variables: 
                            a:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: -1
                            b:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 100
                                increment: 10
                                solution: 30
                            d:
                                start: 0
                                min: 0
                                max: 100
                                increment: 10
                                solution: null
                    }
                    {
                        id: 1364507658841
                        equations:
                            'a*x-d':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                    {fragment: '-d', after: 'x'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        rings: [
                            {x: 19, y: -5}
                            {x: 22, y: 10}
                            {x: 25, y: 25}
                        ]
                        grid:
                            xMin: -40
                            xMax: 40
                            yMin: -40
                            yMax: 40
                        islandCoordinates: {x: 16, y: -20}
                        variables: 
                            a:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: 5
                            b:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 100
                                increment: 10
                                solution: null
                            d:
                                start: 0
                                min: 0
                                max: 100
                                increment: 10
                                solution: 100
                    }
                    {
                        id: 1364509365255
                        equations:
                            'a*x-d':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                    {fragment: '-d', after: 'x'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        rings: [
                            {x: -35, y: 10}
                            {x: -31, y: -14}
                            {x: -27, y: -38}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -39, y: 34}
                        variables: 
                            a:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: -6
                            b:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 1000
                                increment: 100
                                solution: null
                            d:
                                start: 0
                                min: 0
                                max: 1000
                                increment: 100
                                solution: 200
                    }
                    {
                        id: 1364660915098
                        equations:
                            '(1/b)*x+c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                    {fragment: '+c', after: 'x'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '+d']
                        rings: [
                            {x: 0, y: 8}
                            {x: 8, y: 10}
                            {x: 16, y: 12}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: -8, y: 6}
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
                                solution: 4
                            c:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 8
                            d:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                    }
                    {
                        id: 1364662433501
                        equations:
                            '(1/b)*x+c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                    {fragment: '+c', after: 'x'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        rings: [
                            {x: -10, y: 13}
                            {x: 0, y: 12}
                            {x: 10, y: 11}
                            {x: 20, y: 10}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -20, y: 14}
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
                                solution: -10
                            c:
                                start: 0
                                min: 0
                                max: 20
                                increment: 1
                                solution: 12
                            d:
                                start: 0
                                min: 0
                                max: 20
                                increment: 1
                                solution: null
                    }
                ]
            }
        ]
    }
    {
        stages: [
            {
                name: 'Multiple Lines (Shifting)'
                levels: [
                    {
                        id: 1364510572027
                        equations:
                            'x-3':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-3', after: 'x'}
                                ]
                            '-x-3':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-3', after: '-x'}
                                ]
                        fragments: ['-3', '-3']
                        rings: [
                            {x: -3, y: 0}
                            {x: -1, y: -2}
                            {x: 1, y: -2}
                            {x: 3, y: 0}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -6, y: 3}
                    }
                    {
                        id: 1364520496399
                        equations:
                            'x+8':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+8', after: 'x'}
                                ]
                            '-x+8':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+8', after: '-x'}
                                ]
                        fragments: ['+8', '+8']
                        rings: [
                            {x: -10, y: 18}
                            {x: 0, y: 8}
                            {x: 10, y: 18}
                            {x: 30, y: 38}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -30, y: 38}
                    }
                    {
                        id: 1364663305243
                        equations:
                            'x+4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+4', after: 'x'}
                                ]
                            '-x+4':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+4', after: '-x'}
                                ]
                        fragments: ['+4', '+4', '-4', '-4']
                        rings: [
                            {x: 0, y: 4}
                            {x: 5, y: 9}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -5, y: 9}
                    }
                    {
                        id: 1364663411940
                        equations:
                            'x+7':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+7', after: 'x'}
                                ]
                            '-x+7':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+7', after: '-x'}
                                ]
                        fragments: ['+7', '+7', '-7', '-7']
                        rings: [
                            {x: 0, y: 7}
                            {x: 7, y: 14}
                        ]
                        grid:
                            xMin: -15
                            xMax: 15
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -7, y: 14}
                    }
                    {
                        id: 1364663552537
                        equations:
                            'x-5':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-5', after: 'x'}
                                ]
                            '-x-5':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-5', after: '-x'}
                                ]
                        fragments: ['+5', '+5', '-5', '-5']
                        rings: [
                            {x: 0, y: -5}
                            {x: 5, y: 0}
                            {x: 10, y: 5}
                        ]
                        grid:
                            xMin: -12
                            xMax: 12
                            yMin: -12
                            yMax: 12
                        islandCoordinates: {x: -5, y: 0}
                    }
                    {
                        id: 1364664368228
                        equations:
                            'x-10':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-10', after: 'x'}
                                ]
                            '-x+10':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+10', after: '-x'}
                                ]
                        fragments: ['+10', '+10', '-10', '-10']
                        rings: [
                            {x: 10, y: 0}
                            {x: 15, y: -5}
                            {x: 20, y: -10}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: 5, y: -5}
                    }
                    {
                        id: 1364664483654
                        equations:
                            'x-4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-4', after: 'x'}
                                ]
                            '-x+4':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+4', after: '-x'}
                                ]
                        fragments: ['+4', '-4', '+4', '-4']
                        rings: [
                            {x: 2, y: -2}
                            {x: 4, y: 0}
                            {x: 6, y: -2}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: 0, y: -4}
                    }
                    {
                        id: 1364664770523
                        equations:
                            'x-15':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-15', after: 'x'}
                                ]
                            '-x+15':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+15', after: '-x'}
                                ]
                        fragments: ['+15', '+15', '-15', '-15']
                        rings: [
                            {x: 0, y: 15}
                            {x: 15, y: 0}
                            {x: 30, y: 15}
                        ]
                        grid:
                            xMin: -35
                            xMax: 35
                            yMin: -35
                            yMax: 35
                        islandCoordinates: {x: -15, y: 30}
                    }
                    {
                        id: 1364665016074
                        equations:
                            'x+3':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+3', after: 'x'}
                                ]
                            '-x-3':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-3', after: '-x'}
                                ]
                        fragments: ['+3', '+3', '-3', '-3']
                        rings: [
                            {x: -3, y: 0}
                            {x: 0, y: 3}
                            {x: 3, y: 6}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -6, y: 3}
                    }
                    {
                        id: 1364665383114
                        equations:
                            'x+20':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+20', after: 'x'}
                                ]
                            '-x-20':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-20', after: '-x'}
                                ]
                        fragments: ['+20', '+20', '-20', '-20']
                        rings: [
                            {x: -30, y: -10}
                            {x: -20, y: 0}
                            {x: -10, y: -10}
                            {x: 0, y: -20}
                            {x: 10, y: -30}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -40, y: -20}
                    }
                    {
                        id: 1364511419224
                        equations:
                            'x+4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+4', after: 'x'}
                                ]
                            '-x+6':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+6', after: '-x'}
                                ]
                        fragments: ['+4', '+6', '-4', '-6']
                        rings: [
                            {x: -4, y: 0}
                            {x: 0, y: 4}
                            {x: 6, y: 0}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: -10, y: -6}
                    }
                    {
                        id: 1364511618594
                        equations:
                            'x+9':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+9', after: 'x'}
                                ]
                            '-x-5':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-5', after: '-x'}
                                ]
                        fragments: ['+5', '-5', '+9', '-9']
                        rings: [
                            {x: -18, y: 13}
                            {x: 0, y: 9}
                            {x: 20, y: 29}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -37, y: 32}
                    }
                    {
                        id: 1364512372898
                        equations:
                            'x-8':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-8', after: 'x'}
                                ]
                            '-x+4':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+4', after: '-x'}
                                ]
                        fragments: ['+4', '-4', '+8', '-8']
                        rings: [
                            {x: 5, y: -3}
                            {x: 7, y: -3}
                            {x: 10, y: -6}
                        ]
                        grid:
                            xMin: -5
                            xMax: 15
                            yMin: -15
                            yMax: 5
                        islandCoordinates: {x: 2, y: -6}
                    }
                    {
                        id: 1364676651132
                        equations:
                            'x+9':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+9', after: 'x'}
                                ]
                            '-x-3':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-3', after: '-x'}
                                ]
                        fragments: ['+3', '-3', '+9', '-9']
                        rings: [
                            {x: -9, y: 0}
                            {x: -6, y: 3}
                            {x: -3, y: 0}
                            {x: 0, y: -3}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: -12, y: -3}
                    }
                    {
                        id: 1364676990129
                        equations:
                            'x-12':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-12', after: 'x'}
                                ]
                            '-x+5':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+5', after: '-x'}
                                ]
                        fragments: ['+5', '-5', '+12', '-12']
                        rings: [
                            {x: 0, y: 5}
                            {x: 5, y: 0}
                            {x: 12, y: 0}
                            {x: 8.5, y: -3.5}
                            {x: 17, y: 5}
                        ]
                        grid:
                            xMin: -30
                            xMax: 30
                            yMin: -30
                            yMax: 30
                        islandCoordinates: {x: -5, y: 10}
                    }
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
                        id: 1364513384695
                        equations:
                            'x-c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-c', after: 'x'}
                                ]
                            '-x+a':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+a', after: '-x'}
                                ]
                        fragments: ['+a', '+b', '-c', '-d']
                        rings: [
                            {x: 4, y: -2}
                            {x: 8, y: -2}
                            {x: 6, y: 0}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: 2, y: -4}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 6
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 6
                            d:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                    }
                    {
                        id: 1364513866024
                        equations:
                            'x+a':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+a', after: 'x'}
                                ]
                            '-x':
                                start: '-x'
                        fragments: ['+a', '+b', '-c', '-d']
                        rings: [
                            {x: -10, y: 10}
                            {x: 5, y: -5}
                            {x: 20, y: -20}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -35, y: -5}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 50
                                increment: 5
                                solution: 30
                            b:
                                start: 0
                                min: 0
                                max: 50
                                increment: 5
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 50
                                increment: 5
                                solution: null
                            d:
                                start: 0
                                min: 0
                                max: 50
                                increment: 5
                                solution: null
                    }     
                    {
                        id: 1364677454929
                        equations:
                            'x+b':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+b', after: 'x'}
                                ]
                            '-x+a':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '+a', after: '-x'}
                                ]
                        fragments: ['+a', '+b', '-c', '-d']
                        rings: [
                            {x: 0, y: 4}
                            {x: 2, y: 6}
                            {x: 4, y: 4}
                            {x: 6, y: 2}
                            {x: 8, y: 0}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -2, y: 2}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 8
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                            c:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            d:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                    }
                    {
                        id: 1364680353131
                        equations:
                            'x-c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-c', after: 'x'}
                                ]
                            '-x-d':
                                start: '-x'
                                solutionComponents: [
                                    {fragment: '-d', after: '-x'}
                                ]
                        fragments: ['+a', '+b', '-c', '-d']
                        rings: [
                            {x: -1, y: -5}
                            {x: 4, y: 0}
                            {x: 1.5, y: -2.5}
                            {x: -3.5, y: -2.5}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -6, y: 0}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                            d:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 6
                    }
                ]
            }
            {
                name: 'Multiple Lines (Shift And Slope)'
                levels: [
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
                        id: 1364680927728
                        equations:
                            '3*x-3':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '3*', after: ''}
                                    {fragment: '-3', after: 'x'}
                                ]
                            '(1/3)*x+3':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/3)*', after: ''}
                                    {fragment: '+3', after: 'x'}
                                ]
                        fragments: ['3*', '(1/3)*', '+3', '-3']
                        rings: [
                            {x: 2, y: 3}
                            {x: 3, y: 4}
                            {x: 6, y: 5}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: 1, y: 0}
                    }
                    {
                        id: 1364681731709
                        equations:
                            '2*x-4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '2*', after: ''}
                                    {fragment: '-4', after: 'x'}
                                ]
                            '-2*x+4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-2*', after: ''}
                                    {fragment: '+4', after: 'x'}
                                ]
                        fragments: ['2*', '-2*', '+4', '-4']
                        rings: [
                            {x: 0, y: 4}
                            {x: 2, y: 0}
                            {x: 4, y: 4}
                            {x: 6, y: 8}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -2, y: 8}
                    }
                    {
                        id: 1364682012844
                        equations:
                            '(1/4)*x+6':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/4)*', after: ''}
                                    {fragment: '+6', after: 'x'}
                                ]
                            '(-1/4)*x-6':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(-1/4)*', after: ''}
                                    {fragment: '-6', after: 'x'}
                                ]
                        fragments: ['(1/4)*', '(-1/4)*', '+6', '-6']
                        rings: [
                            {x: -24, y: 0}
                            {x: 0, y: -6}
                            {x: 24, y: -12}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -40, y: -4}
                    }
                    {
                        id: 1364682615198
                        equations:
                            '(-1/5)*x+6':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(-1/5)*', after: ''}
                                    {fragment: '+6', after: 'x'}
                                ]
                            '-5*x+4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-5*', after: ''}
                                    {fragment: '+4', after: 'x'}
                                ]
                        fragments: ['-5*', '(-1/5)*', '+4', '+6']
                        rings: [
                            {x: 0, y: 4}
                            {x: 1, y: -1}
                            {x: 2, y: -6}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -5, y: 7}
                    }
                    {
                        id: 1364683625383
                        equations:
                            '(-1/2)*x+4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(-1/2)*', after: ''}
                                    {fragment: '+4', after: 'x'}
                                ]
                            '(1/2)*x+2':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/2)*', after: ''}
                                    {fragment: '+2', after: 'x'}
                                ]
                        fragments: ['(1/2)*', '(-1/2)*', '+4', '+2']
                        rings: [
                            {x: 0, y: 4}
                            {x: 2, y: 3}
                            {x: 4, y: 4}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -2, y: 5}
                    }
                    {
                        id: 1364683987059
                        equations:
                            '-3*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-3*', after: ''}
                                ]
                            '(-1/3)*x-8':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(-1/3)*', after: ''}
                                    {fragment: '-8', after: 'x'}
                                ]
                        fragments: ['-3*', '(-1/3)*', '+8', '-8']
                        rings: [
                            {x: 0, y: 0}
                            {x: 3, y: -9}
                            {x: 12, y: -12}
                        ]
                        grid:
                            xMin: -15
                            xMax: 15
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -3, y: 9}
                    }
                    {
                        id: 1364684337839
                        equations:
                            '(-1/2)*x+6':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(-1/2)*', after: ''}
                                    {fragment: '+6', after: 'x'}
                                ]
                            'x-6':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-6', after: 'x'}
                                ]
                        fragments: ['2*', '(-1/2)*', '+6', '-6']
                        rings: [
                            {x: 0, y: 6}
                            {x: 8, y: 2}
                            {x: 15, y: 9}
                        ]
                        grid:
                            xMin: -24
                            xMax: 24
                            yMin: -24
                            yMax: 24
                        islandCoordinates: {x: -8, y: 10}
                    }
                    {
                        id: 1364684503216
                        equations:
                            '3*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '3*', after: ''}
                                ]
                            'x+2+4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '+2', after: 'x'}
                                    {fragment: '+4', after: '+2'}
                                ]
                        fragments: ['3*', '-3*', '+2', '+4']
                        rings: [
                            {x: 0, y: 6}
                            {x: 3, y: 9}
                            {x: -3, y: 3}
                            {x: 5, y: 15}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: -6, y: 0}
                    }
                    {
                        id: 1364684743255
                        equations:
                            '4*(-1/2)*x':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '4*', after: ''}
                                    {fragment: '(-1/2)*', after: '4*'}
                                ]
                            'x-2-4':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '-2', after: 'x'}
                                    {fragment: '-4', after: '-2'}
                                ]
                        fragments: ['4*', '(-1/2)*', '-2', '-4']
                        rings: [
                            {x: 2, y: -4}
                            {x: 6, y: 0}
                            {x: 0, y: 0}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -2, y: 4}
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
                        id: 1364688231845
                        equations:
                            '(1/b)*x+c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                    {fragment: '+c', after: 'x'}
                                ]
                            'a*x+d':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                    {fragment: '+d', after: 'x'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '+d']
                        rings: [
                            {x: -2, y: -3}
                            {x: 2, y: -2}
                            {x: 3, y: 2}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -6, y: -1}
                        variables: 
                            a:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: 4
                            b:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: -2
                            c:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: -4
                            d:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: -10
                    }
                    {
                        id: 1364689024728
                        equations:
                            '(1/b)*x+c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                    {fragment: '+c', after: 'x'}
                                ]
                            'a*x+d':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                    {fragment: '+d', after: 'x'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '+d']
                        rings: [
                            {x: 0, y: 6}
                            {x: 2, y: 0}
                            {x: 3, y: -5}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -5, y: 5}
                        variables: 
                            a:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: -5
                            b:
                                start: 1
                                min: -10
                                max: 10
                                increment: 1
                                solution: 5
                            c:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: 6
                            d:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: 10
                    }
                    {
                        id: 1364691092643
                        equations:
                            '(1/b)*x+c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                    {fragment: '+c', after: 'x'}
                                ]
                            'a*x+d':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                    {fragment: '+d', after: 'x'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '+d']
                        rings: [
                            {x: 0, y: 8}
                            {x: -16, y: 4}
                            {x: 15, y: 20}
                            {x: 22, y: 34}
                        ]
                        grid:
                            xMin: -50
                            xMax: 50
                            yMin: -50
                            yMax: 50
                        islandCoordinates: {x: -32, y: 0}
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
                                solution: 4
                            c:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: 8
                            d:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: -10
                    }
                    {
                        id: 1364691431977
                        equations:
                            'a*x+c':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: 'a*', after: ''}
                                    {fragment: '+c', after: 'x'}
                                ]
                            '(1/b)*x+d':
                                start: 'x'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                    {fragment: '+d', after: 'x'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '+d']
                        rings: [
                            {x: -3, y: 4}
                            {x: -2, y: 0}
                            {x: 0, y: -4}
                            {x: 4, y: -5}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -4, y: 8}
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
                                solution: -4
                            c:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: -8
                            d:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: -4
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
        ]
    }
    {
        stages: [
            {
                name: 'Curves'
                levels: [
                    {
                        id: 1364744280392
                        equations:
                            '(x)^2+5':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '+5', after: '(x)^2'}
                                ]
                        fragments: ['+5']
                        rings: [
                            {x: -2, y: 9}
                            {x: 0, y: 5}
                            {x: 2, y: 9}
                            {x: 3, y: 14}
                        ]
                        grid:
                            xMin: -16
                            xMax: 16
                            yMin: -16
                            yMax: 16
                        islandCoordinates: {x: -3, y: 14}
                    }
                    {
                        id: 1364744509304
                        equations:
                            '(x+5)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '+5', after: 'x'}
                                ]
                        fragments: ['+5']
                        rings: [
                            {x: -7, y: 4}
                            {x: -5, y: 0}
                            {x: -3, y: 4}
                            {x: -2, y: 9}
                        ]
                        grid:
                            xMin: -13
                            xMax: 13
                            yMin: -13
                            yMax: 13
                        islandCoordinates: {x: -8, y: 9}
                    }
                    {
                        id: 1364747040078
                        equations:
                            '(x+a)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '+a', after: 'x'}
                                ]
                        fragments: ['+a', '-b']
                        rings: [
                            {x: -6, y: 4}
                            {x: -4, y: 0}
                            {x: -2, y: 4}
                            {x: -1, y: 9}
                        ]
                        grid:
                            xMin: -12
                            xMax: 12
                            yMin: -12
                            yMax: 12
                        islandCoordinates: {x: -7, y: 9}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                    }
                    {
                        id: 1364747096861
                        equations:
                            '(x-b)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '-b', after: 'x'}
                                ]
                        fragments: ['+a', '-b']
                        rings: [
                            {x: 1, y: 4}
                            {x: 3, y: 0}
                            {x: 5, y: 4}
                            {x: 6, y: 9}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: 0, y: 9}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 3
                    }
                    {
                        id: 1364747173461
                        equations:
                            '(x)^2-b':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '-b', after: '(x)^2'}
                                ]
                        fragments: ['+a', '-b']
                        rings: [
                            {x: -2, y: 0}
                            {x: 0, y: -4}
                            {x: 2, y: 0}
                            {x: 3, y: 5}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -3, y: 5}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                    }
                    {
                        id: 1364747296870
                        equations:
                            '(x)^2+a':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '+a', after: '(x)^2'}
                                ]
                        fragments: ['+a', '-b']
                        rings: [
                            {x: -2, y: 9}
                            {x: 0, y: 5}
                            {x: 2, y: 9}
                            {x: 4, y: 21}
                        ]
                        grid:
                            xMin: -25
                            xMax: 25
                            yMin: -25
                            yMax: 25
                        islandCoordinates: {x: -4, y: 21}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 5
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                    }
                    {
                        id: 1364747386370
                        equations:
                            '(x)^2-b':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '-b', after: '(x)^2'}
                                ]
                        fragments: ['+a', '-b']
                        rings: [
                            {x: -3, y: 1}
                            {x: 0, y: -8}
                            {x: 3, y: 1}
                            {x: 4, y: 8}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -4, y: 8}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 8
                    }
                    {
                        id: 1364748866298
                        equations:
                            '(x-b)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '-b', after: 'x'}
                                ]
                        fragments: ['+a', '-b']
                        rings: [
                            {x: 3, y: 4}
                            {x: 5, y: 0}
                            {x: 7, y: 4}
                            {x: 8, y: 9}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: 2, y: 9}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 5
                    }
                    {
                        id: 1364749088810
                        equations:
                            '(x+a)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '+a', after: 'x'}
                                ]
                        fragments: ['+a', '-b']
                        rings: [
                            {x: -7, y: 4}
                            {x: -5, y: 0}
                            {x: -3, y: 4}
                            {x: -2, y: 9}
                        ]
                        grid:
                            xMin: -12
                            xMax: 12
                            yMin: -12
                            yMax: 12
                        islandCoordinates: {x: -8, y: 9}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 5
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                    }
                    {
                        id: 1364749328433
                        equations:
                            '(x-b)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '-b', after: 'x'}
                                ]
                        fragments: ['+a', '-b']
                        rings: [
                            {x: 0, y: 4}
                            {x: 2, y: 0}
                            {x: 4, y: 4}
                            {x: 5, y: 9}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -1, y: 9}
                        variables: 
                            a:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            b:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 2
                    }
                    {
                        id: 1364750857551
                        equations:
                            '(2*x)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '2*', after: '('}
                                ]
                        fragments: ['2*']
                        rings: [
                            {x: -1, y: 4}
                            {x: 0, y: 0}
                            {x: 1, y: 4}
                            {x: 2, y: 16}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -2
                            yMax: 18
                        islandCoordinates: {x: -2, y: 16}
                    }
                    {
                        id: 1364751046543
                        equations:
                            '((1/b)*x)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: '('}
                                ]
                        fragments: ['a*', '(1/b)*']
                        rings: [
                            {x: -6, y: 4}
                            {x: 0, y: 0}
                            {x: 6, y: 4}
                            {x: 9, y: 9}
                        ]
                        grid:
                            xMin: -15
                            xMax: 15
                            yMin: -15
                            yMax: 15
                        islandCoordinates: {x: -9, y: 9}
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
                                solution: 3
                    }
                    {
                        id: 1364751232601
                        equations:
                            '((1/b)*x)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: '('}
                                ]
                        fragments: ['a*', '(1/b)*']
                        rings: [
                            {x: -12, y: 9}
                            {x: -8, y: 4}
                            {x: 0, y: 0}
                            {x: 8, y: 4}
                            {x: 12, y: 9}
                            {x: 16, y: 16}
                        ]
                        grid:
                            xMin: -24
                            xMax: 24
                            yMin: -24
                            yMax: 24
                        islandCoordinates: {x: -16, y: 16}
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
                                solution: 4
                    }
                    {
                        id: 1364751644627
                        equations:
                            '(1/b)*(x)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                ]
                        fragments: ['a*', '(1/b)*']
                        rings: [
                            {x: -4, y: 4}
                            {x: 0, y: 0}
                            {x: 4, y: 4}
                            {x: 6, y: 9}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -6, y: 9}
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
                                solution: 4
                    }
                    {
                        id: 1364752362148
                        equations:
                            '(1/b)*(x)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                ]
                        fragments: ['a*', '(1/b)*']
                        rings: [
                            {x: -3, y: 1.5}
                            {x: 0, y: 0}
                            {x: 3, y: 1.5}
                            {x: 6, y: 6}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -10
                            yMax: 10
                        islandCoordinates: {x: -6, y: 6}
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
                                solution: 6
                    }
                    {
                        id: 1364754136172
                        equations:
                            '((1/b)*x)^2-d':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: '('}
                                    {fragment: '-d', after: '((1/b)*x)^2'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        rings: [
                            {x: -6, y: 0}
                            {x: 0, y: -4}
                            {x: 6, y: 0}
                            {x: 9, y: 5}
                        ]
                        grid:
                            xMin: -12
                            xMax: 12
                            yMin: -12
                            yMax: 12
                        islandCoordinates: {x: -9, y: 5}
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
                                solution: 3
                            c:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                            d:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                    }
                    {
                        id: 1364754325573
                        equations:
                            '(a*x+c)^2':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: 'a*', after: '('}
                                    {fragment: '+c', after: 'x'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        rings: [
                            {x: -2, y: 0}
                            {x: -1, y: 4}
                        ]
                        grid:
                            xMin: -6
                            xMax: 6
                            yMin: -6
                            yMax: 6
                        islandCoordinates: {x: -3, y: 4}
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
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                            d:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: null
                    }
                    {
                        id: 1364756059524
                        equations:
                            '(a*x+c)^2-d':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: 'a*', after: '('}
                                    {fragment: '+c', after: 'x'}
                                    {fragment: '-d', after: '(a*x+c)^2'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        rings: [
                            {x: -6, y: 12}
                            {x: -5, y: 0}
                            {x: -4, y: -4}
                            {x: -3, y: 0}
                            {x: -2, y: 12}
                            {x: -1, y: 32}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -6
                            yMax: 34
                        islandCoordinates: {x: -7, y: 32}
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
                                solution: null
                            c:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 8
                            d:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                    }
                    {
                        id: 1364756652103
                        equations:
                            '(1/b)*(x-d)^2+c':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '(1/b)*', after: ''}
                                    {fragment: '-d', after: 'x'}
                                    {fragment: '+c', after: '(x-d)^2'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '-d']
                        rings: [
                            {x: 0, y: 0}
                            {x: 2, y: 3}
                            {x: 4, y: 4}
                            {x: 6, y: 3}
                            {x: 8, y: 0}
                        ]
                        grid:
                            xMin: -10
                            xMax: 10
                            yMin: -12
                            yMax: 8
                        islandCoordinates: {x: -2, y: -5}
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
                                solution: -4
                            c:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                            d:
                                start: 0
                                min: 0
                                max: 10
                                increment: 1
                                solution: 4
                    }
                    {
                        id: 1364757076047
                        equations:
                            '(x+c)^2+d':
                                start: '(x)^2'
                                solutionComponents: [
                                    {fragment: '+c', after: 'x'}
                                    {fragment: '+d', after: '(x+c)^2'}
                                ]
                        fragments: ['a*', '(1/b)*', '+c', '+d']
                        rings: [
                            {x: 3, y: 12}
                            {x: 6, y: 3}
                            {x: 9, y: 12}
                            {x: 10, y: 19}
                        ]
                        grid:
                            xMin: -20
                            xMax: 20
                            yMin: -20
                            yMax: 20
                        islandCoordinates: {x: 2, y: 19}
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
                                solution: null
                            c:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: -6
                            d:
                                start: 0
                                min: -10
                                max: 10
                                increment: 1
                                solution: 3
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
        ]
    }
    {
        stages: [
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
    }
]


