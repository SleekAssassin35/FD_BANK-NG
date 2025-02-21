Config = {}

-- Enable debug mode
Config.Debug = false

-- How much shared account can user add
Config.MaxSharedAccounts = 3

-- If you want to use society accounts, please set this to true
Config.UseSocietyAccounts = false

-- If you want qb-management table to be updated automatically, please set this to true
Config.UpdateQbManagementTable = true
Config.QbManagementTableName = 'management_funds'

-- If you want to use gang accounts, please set this to true
Config.UseGangAccounts = true

-- Billing command, set to false to disable it
Config.BillingCommand = 'faturalar'


-- Personal invoices are disabled by default, if you want to enable them, please set this to true
Config.PersonalInvoicesAllowed = true

-- Choose what societies can issue invoices
Config.SocietiesInvoicesEnabled = {
    ['police'] = true,
    ['ambulance'] = true,
    ['mechanic'] = true
}

-- Choose what societys can lookup how much in dept is citizen
Config.SocietiesCitizenInvoicesLookup = {
    ['police'] = true,
    ['ambulance'] = true,
    ['mechanic'] = true
}

-- How many days player has to pay invoice. Provide number in days
Config.InvoiceDueInDays = 7

-- If you want to force invoice payment for societies, please set societys below
Config.ForceInvoicePaymentForSocietys = {
    ['police'] = true,
    ['ambulance'] = true
}

-- Do you want to enable freezing of accounts?
Config.IsFreezingEnabled = true
Config.FreezingCommand = 'faccount'
Config.UnfreezingCommand = 'ufaccount'

-- Choose what societies can freeze accounts, provide society with minimum rank
Config.SocietyCanFreeze = {
    ['police'] = 3,
    ['ambulance'] = 3
}
Config.AdminPermissionToFreeze = 'admin'


-- Discord webhook for logging
Config.DiscordWebhooks = {
    ['transactionExport'] = '',
}

-- Do you want to enable usage tracking?
Config.EnableUsageTracking = true
Config.TrackingCommand = 'tplayer'
Config.UntrackCommand = 'utplayer'

-- Choose what societies can track accounts, provide society with minimum rank
Config.SocietyCanUseTracking = {
    ['ambulance'] = 3,
    ['police'] = 3
}

Config.AdminPermissionToTrack = 'admin'

-- Bank locations and usage
--[[
    You can use two types of interaction:
    - ox_target
    - points

    If you want to use ox_target, please provide target with coords, size and rotation
    If you want to use points, please provide point with coords
]]--
Config.ForInteractionsUse = 'points'
Config.Banks = {
    ['legion'] = {
        locations = {
            {
                name = 'Legion Square',
                target = {
                    coords = vec3(149.7, -1041.4, 30.0),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 339.5,
                },
                point = vector3(149.93, -1040.85, 29.37)
            },
            {
                name = 'Legion Square',
                target = {
                    coords = vec3(148.3, -1040.85, 30.0),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 339.75,
                },
                point = vector3(148.44, -1040.3, 29.38)
            }

        },
        blip = {
            enabled = false,
            coords = vector3(149.63, -1039.21, 29.37),
            display = 4,
            sprite = 108,
            color = 2,
            scale = 0.55,
            label = locale('bank_legion_blip'),
            isShortRange = true
        },
    },
    ['hawick'] = {
        locations = {
            {
                name = 'Hawick',
                target = {
                    coords = vec3(314.0, -279.75, 54.8),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 339.5,
                },
                point = vector3(314.32, -279.14, 54.17)
            },
            {
                name = 'Hawick',
                target = {
                    coords = vec3(312.6, -279.2, 54.8),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 340.0,
                },
                point = vector3(312.79, -278.67, 54.17)
            }

        },
        blip = {
            enabled = false,
            coords = vector3(314.12, -278.16, 54.17),
            display = 4,
            sprite = 108,
            color = 2,
            scale = 0.55,
            label = locale('bank_hawick_blip'),
            isShortRange = true
        },
    },
    ['hawick_1'] = {
        locations = {
            {
                name = 'Hawick',
                target = {
                    coords = vec3(-351.1, -50.55, 49.65),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 340.5,
                },
                point = vector3(-350.92, -50.01, 49.04)
            },
            {
                name = 'Hawick',
                target = {
                    coords = vec3(-352.5, -50.05, 49.65),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 341.5,
                },
                point = vector3(-352.32, -49.53, 49.05)
            }

        },
        blip = {
            enabled = false,
            coords = vector3(-350.88, -48.6, 49.04),
            display = 4,
            sprite = 108,
            color = 2,
            scale = 0.55,
            label = locale('bank_hawick_blip'),
            isShortRange = true
        },
    },
    ['del_perro'] = {
        locations = {
            {
                name = 'Del Perro',
                target = {
                    coords = vec3(-1212.35, -331.3, 38.4),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 26.0,
                },
                point = vector3(-1212.62, -330.76, 37.79)
            },
            {
                name = 'Del Perro',
                target = {
                    coords = vec3(-1213.7, -332.0, 38.4),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 26.0,
                },
                point = vector3(-1213.97, -331.46, 37.79)
            }

        },
        blip = {
            enabled = false,
            coords = vector3(-1213.21, -329.57, 37.78),
            display = 4,
            sprite = 108,
            color = 2,
            scale = 0.55,
            label = locale('bank_del_perro_blip'),
            isShortRange = true
        },
    },
    ['great_ocean'] = {
        locations = {
            {
                name = 'Great Ocean',
                target = {
                    coords = vec3(-2961.9, 482.9, 16.35),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 87.5,
                },
                point = vector3(-2962.47, 482.97, 15.7)
            },
            {
                name = 'Great Ocean',
                target = {
                    coords = vec3(-2962.0, 481.35, 16.35),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 87.5,
                },
                point = vector3(-2962.58, 481.39, 15.71)
            }

        },
        blip = {
            enabled = false,
            coords = vector3(-2963.77, 483.1, 15.7),
            display = 4,
            sprite = 108,
            color = 2,
            scale = 0.55,
            label = locale('bank_del_perro_blip'),
            isShortRange = true
        },
    },
    ['route_68'] = {
        locations = {
            {
                name = 'Route 68',
                target = {
                    coords = vec3(1175.0, 2707.45, 38.7),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 0.0,
                },
                point = vector3(1175.0, 2706.91, 38.09)
            },
            {
                name = 'Route 68',
                target = {
                    coords = vec3(1176.5, 2707.45, 38.75),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 0.0,
                },
                point = vector3(1176.51, 2706.89, 38.1)
            }

        },
        blip = {
            enabled = false,
            coords = vector3(1175.09, 2704.85, 38.1),
            display = 4,
            sprite = 108,
            color = 2,
            scale = 0.55,
            label = locale('bank_route_68_blip'),
            isShortRange = true
        },
    },
    ['pacific'] = {
        locations = {
            {
                name = 'Pacific',
                target = {
                    coords = vec3(241.6, 226.05, 106.8),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 339.0,
                },
                point = vector3(241.34, 225.39, 106.29)
            },
            {
                name = 'Pacific',
                target = {
                    coords = vec3(243.35, 225.4, 106.8),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 339.0,
                },
                point = vector3(243.22, 224.8, 106.29)
            },
            {
                name = 'Pacific',
                target = {
                    coords = vec3(246.8, 224.2, 106.8),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 339.0,
                },
                point = vector3(246.62, 223.63, 106.29)
            },
            {
                name = 'Pacific',
                target = {
                    coords = vec3(248.55, 223.55, 106.8),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 339.0,
                },
                point = vector3(248.37, 222.9, 106.29)
            }

        },
        blip = {
            enabled = false,
            coords = vector3(235.42, 216.97, 106.29),
            display = 4,
            sprite = 108,
            color = 2,
            scale = 0.55,
            label = locale('bank_pacific_blip'),
            isShortRange = true
        },
    },
    ['paleto'] = {
        locations = {
            {
                name = 'Paleto',
                target = {
                    coords = vec3(-112.7, 6470.6, 32.25),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 316.5,
                },
                point = vector3(-113.12, 6470.34, 31.63)
            },
            {
                name = 'Paleto',
                target = {
                    coords = vec3(-111.65, 6469.6, 32.3),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 316.5,
                },
                point = vector3(-111.98, 6469.17, 31.63)
            },
            {
                name = 'Paleto',
                target = {
                    coords = vec3(-110.5, 6468.45, 32.3),
                    size = vec3(1.0, 0.50000000000001, 1.15),
                    rotation = 316.5,
                },
                point = vector3(-110.96, 6468.11, 31.63)
            }
        },
        blip = {
            enabled = false,
            coords = vector3(-112.01, 6466.94, 31.63),
            display = 4,
            sprite = 108,
            color = 2,
            scale = 0.55,
            label = locale('bank_paleto_blip'),
            isShortRange = true
        },
    },
}

Config.ATMModels = { `prop_atm_01`, `prop_atm_02`, `prop_atm_03`, `prop_fleeca_atm` }

Config.ATMPoints = {
    -- DOWNTOWN LOS SANTOS:
    -- Peaceful Street

    vector3(-303.33, -829.73, 32.42),
    vector3(-301.72, -830.01, 32.42),
    vector3(-258.9, -723.44, 33.48),
    vector3(-256.22, -716.04, 33.52),
    vector3(-254.33, -692.47, 33.61),

    --Lombank Tower
    vector3(24.48, -945.95, 29.36),
    vector3(5.3, -919.81, 29.56),

    -- All Fleecas
    vector3(146.02, -1035.21, 29.34),
    vector3(147.59, -1035.78, 29.34),
    vector3(-1205.73, -324.83, 37.86),
    vector3(-1205.0, -326.34, 37.84),
    vector3(-2959.0, 487.74, 15.46),
    vector3(-2956.85, 487.64, 15.46),
    vector3(1171.5, 2702.57, 38.18),
    vector3(1172.51, 2702.58, 38.17),

    --Vespucci Boulevard:
    --Between Arirang Plaza and Kayton Banking
    vector3(-712.97, -818.94, 23.73),
    vector3(-710.07, -818.9, 23.73),

    --Digital Den
    vector3(-660.66, -854.07, 24.49),
    vector3(1138.22, -469.0, 66.73),

    --Blick
    vector3(-537.81, -854.51, 29.29),

    --Go Postal
    vector3(89.64, 2.46, 68.31),

    --San Andreas Avenue:
    --FBI Headquarters
    vector3(114.41, -776.4, 31.42),
    vector3(111.25, -775.24, 31.44),

    --Maison Ricard
    vector3(119.03, -883.73, 31.12),
    vector3(112.63, -819.42, 31.34),

    --Union Depository
    vector3(-28.03, -724.61, 44.23),
    vector3(-30.24, -723.69, 44.23),

    --707 Vespucci
    vector3(-203.89, -861.4, 30.27),

    --Robert Dazzler International Jewelry Exchange
    vector3(296.49, -894.15, 29.23),
    vector3(295.75, -896.07, 29.22),

    --VINEWOOD:
    --POP'S PILLS:
    vector3(89.64, 2.46, 68.31),
    vector3(155.85, 6642.89, 31.6),
    vector3(174.14, 6637.89, 31.57),

    --Hardcore Comic Store:
    vector3(-165.12, 232.69, 94.92),
    vector3(-165.13, 234.76, 94.92),

    --Chico's Hypermarket:
    vector3(1077.77, -776.54, 58.24),
    vector3(1166.91, -456.08, 66.81),

    --Hawick Avenue:
    vector3(-57.66, -92.64, 57.78),

    --Mall souvenir gift shop:
    vector3(356.95, 173.53, 103.07),

    --PACIFIC BANKO ATM:
    vector3(238.33, 215.98, 106.29),
    vector3(237.88, 216.92, 106.29),
    vector3(237.46, 217.84, 106.29),
    vector3(236.97, 218.77, 106.29),
    vector3(236.59, 219.7, 106.29),
    vector3(265.84, 213.95, 106.28),
    vector3(265.5, 212.93, 106.28),
    vector3(265.14, 212.03, 106.28),
    vector3(264.8, 211.03, 106.28),
    vector3(264.46, 210.08, 106.28),

    --South Rockford Drive:
    vector3(-821.7, -1081.96, 11.13),

    --Little Seoul:
    --Little Seoul Tower:
    vector3(-611.9, -704.84, 31.24),
    vector3(-614.56, -704.84, 31.24),
    vector3(-618.24, -706.85, 30.05),
    vector3(-618.24, -708.86, 30.05),

    --Del Perro:
    --Astro Theaters:
    vector3(-1305.35, -706.44, 25.32),

    --Bay City Avenue:
    vector3(-1570.98, -547.33, 34.96),
    vector3(-1570.05, -546.65, 34.96),

    --Morningwood:
    --International Online Unlimited:
    vector3(-846.74, -340.2, 38.68),
    vector3(-846.28, -341.27, 38.68),

    --Rockford Hills:
    --Mad Wayne Thunder Drive:
    vector3(-867.67, -186.04, 37.84),
    vector3(-866.66, -187.76, 37.84),

    --International Online Unlimited building:
    vector3(-1410.31, -98.79, 52.43),
    vector3(-1410.31, -98.79, 52.43),

    --Leopolds:
    vector3(-721.08, -415.48, 34.98),

    --Vanilla Unicorn:
    vector3(129.23, -1291.13, 29.27),
    vector3(129.68, -1291.91, 29.27),
    vector3(130.12, -1292.68, 29.27),

    --Rob's Liquor:
    vector3(-2975.1, 380.14, 15.0),

    --24/7 All shops:
    vector3(-3241.23, 997.5, 12.55),
    vector3(-3240.6, 1008.63, 12.83),
    vector3(380.8, 323.4, 103.57),
    vector3(33.2, -1348.26, 29.5),
    vector3(2558.5, 389.48, 108.62),
    vector3(-3040.72, 593.11, 7.91),
    vector3(1735.2, 6410.53, 35.04),
    vector3(1701.27, 6426.48, 32.76),
    vector3(1968.12, 3743.56, 32.34),
    vector3(540.32, 2671.14, 42.16),
    vector3(2683.13, 3286.59, 55.24),

    --Limited Service:
    vector3(1153.67, -326.8, 69.21),
    vector3(-717.61, -915.65, 19.22),
    vector3(-57.0, -1752.12, 29.42),
    vector3(-1827.21, 784.87, 138.3),
    vector3(1702.96, 4933.6, 42.06),

    --Chumash Plaza:
    vector3(-3144.38, 1127.58, 20.86),

    --Great Chaparral:
    --Route 68:
    vector3(-1091.45, 2708.58, 18.95),

    --Paleto Bay:
    --Near Sheriff's office:
    vector3(-386.88, 6046.1, 31.5),

    --Near Paleto Bank:
    vector3(-95.55, 6457.1, 31.46),
    vector3(-97.32, 6455.41, 31.47),

    --Sandy Shores:
    --Sandy Shores Medical Center:
    vector3(1822.72, 3683.07, 34.28),

    --Grapeseed:
    --Near Discount Store:
    vector3(1686.85, 4815.83, 42.01),

    --Davis Quartz:
    vector3(2564.51, 2584.76, 38.08),

    --- New
    vector3(-526.62, -1222.97, 18.45),

    vector3(289.11, -1256.78, 29.44),
    vector3(288.84, -1282.33, 29.64),

    -- [[Maze bank]]
    { type = "maze", coords = vector3(-1315.75, -834.68, 16.96) },
    { type = "maze", coords = vector3(-1314.81, -835.96, 16.96) },

    vector3(-2072.37, -317.21, 13.32),
    vector3(-1415.91, -211.99, 46.5),
    vector3(-1430.17, -211.06, 46.5),
    vector3(-1286.27, -213.44, 42.45),
    vector3(-1282.52, -210.92, 42.45),
    vector3(-1289.3, -226.84, 42.45),

    vector3(-596.09, -1161.28, 22.32),
    vector3(-594.6, -1161.3, 22.32),
    vector3(-1109.8, -1690.8, 4.38),
    vector3(527.35, -160.72, 57.09),
    vector3(285.55, 143.44, 104.17),
    vector3(-2295.46, 358.09, 174.6),
    vector3(-2294.69, 356.44, 174.6),
    vector3(-2293.92, 354.8, 174.6),
    vector3(2558.77, 350.96, 108.62),

    vector3(-133.05, 6366.54, 31.48),
    vector3(158.63, 234.2, 106.63)
}
