<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))

searchStandardizerConfig = "<?xml version=""1.0"" encoding=""UTF-8""?>" &_
							"<StandardizerConfiguration Version=""0.1"">" &_
							"<Actions>" &_
								"<NMetalToCoordinate ID=""ChangeN-Metal to Coordinate Bond""/>" &_
							"</Actions>" &_
							"</StandardizerConfiguration>"

stereoStandardizerConfig = "<?xml version=""1.0"" encoding=""UTF-8"" ?>" &_
							"<StandardizerConfiguration Version=""0.1"">" &_
							"<Actions>"&_
								"<Clean2D ID=""Clean 2D"" Type=""Full""/>"&_
								"<RemoveAtomValues ID=""Remove Atom Values""/>"&_
								"<Aromatize ID=""Aromatize""/>"&_								
								"<Tautomerize ID=""Tautomerize""/>"&_
							"</Actions>"&_
							"</StandardizerConfiguration>"
							
defaultStandardizerConfig = "<?xml version=""1.0"" encoding=""UTF-8"" ?>" &_
							"<StandardizerConfiguration Version=""0.1"">" &_
							"<Actions>"&_
								"<Clean/>"&_
								"<RemoveAtomValues/>"&_
							"</Actions>"&_
							"</StandardizerConfiguration>"

standardizerConfigJustClean = "<?xml version=""1.0"" encoding=""UTF-8"" ?>" &_
							"<StandardizerConfiguration Version=""0.1"">" &_
							"<Actions>"&_
								"<Clean/>"&_
							"</Actions>"&_
							"</StandardizerConfiguration>"

configTautomer = "y"
configAbsoluteStereo = "a"
configStereoSearchType = "e"
configStereoModel = "l"
configIgnoreTetrahedralStereo = "n"
configIgnoreDoubleBondStereo = "n"
configIgnoreAlleneStereo = "n"
configIgnoreAxialStereo = "n"
configIgnoreSynAntiStereo = "n"
configExactStereoMatching = "y"
configExactQueryAtomMatching = "y"

regImageExportOptions = "H_hetero"
If whichClient = "ARXSPAN" Or whichClient="EXXON_DEMO" Or whichClient="PETRODEMO" Then
defaultStandardizerConfig = "<?xml version=""1.0"" encoding=""UTF-8"" ?>" &_
							"<StandardizerConfiguration Version=""0.1"">" &_
							"<Actions>"&_
								"<Clean/>"&_
								"<RemoveAtomValues/>"&_
								"<ConvertPiMetalBonds ID=""ConvertPiMetalBonds""/>"&_
								"<WedgeClean ID=""WedgeClean""/>"&_
							"</Actions>"&_
							"</StandardizerConfiguration>"
	regImageExportOptions = "H_hetero,a_bas"
	configTautomer = "n"
	configAbsoluteStereo = "a"
End if
If whichClient="SUNOVION" Or whichClient="ACCORDDEMO" Then
	defaultStandardizerConfig = "<?xml version=""1.0"" encoding=""UTF-8"" ?>" &_
								"<StandardizerConfiguration Version=""0.1"">" &_
								"<Actions>"&_
									"<Aromatize/>"&_
									"<Clean/>"&_
									"<RemoveAtomValues/>"&_
								"</Actions>"&_
								"</StandardizerConfiguration>"
	regImageExportOptions = "H_hetero,-a"
End If
If whichClient="SAGE" Then
	defaultStandardizerConfig = "<?xml version=""1.0"" encoding=""UTF-8"" ?>" &_
								"<StandardizerConfiguration Version=""0.1"">" &_
								"<Actions>"&_
									"<RemoveExplicitH/>"&_
									"<RemoveAtomValues/>"&_
								"</Actions>"&_
								"</StandardizerConfiguration>"
	regImageExportOptions = "H_hetero,-a"
End If
If whichClient="NUVALENT" Then
	defaultStandardizerConfig = "<?xml version=""1.0"" encoding=""UTF-8""?>" &_
								"<StandardizerConfiguration Version=""0.1"">" &_
								  "<Actions>" &_
									"<Clean2D ID=""Clean 2D"" Type=""Partial""/>" &_
									"<Clean2D ID=""Clean 2D"" Type=""TemplateBased"">" &_
									  "<Template format=""base64:gzip:mrv""><![CDATA[H4sIAAAAAAAAAKWX3W+cMAzA3/dXRDzvQpxPUt1dVa0vk1ZpXw97q1KOdkgHdEB7vf9+DnRAqCYtGm2lyNg/O7Fx3O3lS3Ukz0XblU29S4CyhBR13hzK+mGXnMr60Jy6DXDFk8v9Nkdd1K+7XfKz7x8v0vR0OtH8Z1G5l6ameVMl4/uLl64MdE6CNu1DyhmD9MfNp2+Dzaasu97VeYFWXXnRDcJPTe76IZi/uEgr1z6XdTqqp1X7PNJuIbsFuGX0pTsk85Y+4LsrNCX35bEg901buZ48Q0YBN/uePBR10bq+OJC78yDmAs9g/257c93kT1VR9/vtjWeUuTt+69unHAVVcyzyJ8Th4uP1Lqkg2W9d31RXbevOxK+82AFxnDhBnCROEaeJM8RlxFnigOEfvgdUANQAVAHUAVQC1AJUA9TjqMc9h2NijoUP6Pv5scB9kX/+SQge0penoj1/bptHTN7VBfm/X0wY3yVaUcWsEdNDtKaSCcH065MRbagVMOtoojOqtBQy0NGGmUlJeg5IodUfiSJaUiZ1xhdWKBFaLK0UlZabJRklHKZwUGIYZZZb7V0YY7lamBsquLCTuSXaUpZlarI3xADlnGmYA0OJVGa5ZXRhGZhsIQGaaTOfFFoJKjKrM/b6gJdYqThbSDi1BkmLCC2VGOIUoUnIGfOwUUAxpMxOmpJsFEefoBbH40WGSxGIgAoQluMKD0ZrppYvGeWg5gMxamBgphYyjTKB7rnhc+gbhcmxegpooGG1IG3lHYwODTXFtKtAlFGBxcBCEc/YIjFjZNqY1SFgGCAgoGFJSLtwIEencsqXz5gXSYDQqcR8BBnyOzdGzZZmMMRY+SxS2BvSqTnst3dNfVgsSXnYJXeQDF3ja3Hf8dfGkZCmPRQtNuWE/PIf7/jdX9VnD/SmSwAPAb7txAFECPBNKw4gQ4BveXEAFQJ8w4wD6BDgO2kcwLzJgokDZCHAd/s4gA0B/q6IAwALCTa6kgDeEDw0CsHf1AJEpgJW9Tjcl7E7WZXkeNdGMlZVOd7VkYxVYQ73fuTHAevaHGaFSMaqPMdZI5KxqtBxVonsVasaHWedSMa6Yw6zUiRj3TSHWSuSsapTP6vF5oWv69SM814UY1WnnP9rnaaLCyn9M9ni8s3Um84j8bttiv8L7H8DNEkUgD4MAAA=]]></Template>" &_
									  "<Template format=""base64:gzip:mrv""><![CDATA[H4sIAAAAAAAAAKWXTW/jNhCG7/srCJ3XFIffDGwvgt1LgQ3QdnvoLWBkJSvAklJJieN/36GUWJSMAktUSQBi+PIhhzMcMtsvb/WRvJZdX7XNLgPKMlI2RXuomqdddqqaQ3vqN8AVz77stwVqUd/0u+znMDzf5PnpdKLFz7L2b21Di7bOpv6bt75aaE6Ctt1TzhmD/O+77z/GMZuq6QffFCWO6qubfjR+bws/jIv5jyny2nevVZNP8rzuXifaPdh7gHtG3/pDNrv0FftucSh5rI4leWy72g/kFSwFdPYzeSqbsvNDeSAP59HMBe7B/tP27ltbvNRlM+y3d4FRFf74Y+heCjTU7bEsXhCHjd++7bIasv3WD21923X+TEIrmD0Qz4kXxEviFfGaeEO8Jd4RDwz/sB9QAKgAlABqAEWAKkAZoI6jjgcOx8Acy7Cgv87PJfpFfvknI7hJf7yU3fn3rn3G4N3ekP/3iwHju4wr6gxz4uOThBsqmHZMv3+GcEu1sJJdPjmZJMQiQ7mzEIMQjV3zOEW4Q5PSM0mP0wHw2SQI15QZzudF2WBSiikRmyxlVkUjRTApFYmECTNqx9W8UEkEUKssh3mlglPrWOSNIkJScILz2UGhAlzx0NAwE0OXRB9moBAqIJ1EXxeTaJDKxpMApqp2s0lm5IxB2ShNBUYl2t6NMhSEAXMBSjLKtODRJBslqeVXJqbikZNKwBz2d5V06rKdgCYMslkNdBS3TscDNZ5BGWUQOj/ahJZzKN6Hmij2MJoYGKljNyXl2kob5dpGKSqj7AuJFHQa3BwfO8oE7qZeyDS1Rs25C+NGosiOfc64KI5qdNkYIyH2jwX/zGUXFNaJ/FIo9tuHtjlETVIddtkDZGMF+bN87Pl7EclI2x3KDgt0Rv4JB3mqAbfNOQDD0BjAl4BQgtIAYgkIBSwNIJeAUP7SAGoJCMUzDaCXgFBV0wDmygWTBrBXUbBpALcEhHsjDQBsSRivnUTEOhnHayuRscrH6dpLZKxSEtK3E+Q1AhIPBqzyMlzUiUcDVpk5XfyJjFVyTg+HRMYqP6eHRyJjlaLTwyWxWK2SdHr4JDLWWTo+nBIZ66rJ0uPCxTWDJ54WvkrTj8dfEmOVpuGB+WuMPLqR8o9nLjavnsD5/D7+tM3xH4P9vxo5jMRLDAAA]]></Template>" &_
									  "<Template format=""base64:gzip:mrv""><![CDATA[H4sIAAAAAAAAAJVWTW/jNhC9768gdG4kznA4HAa2F0H3UmBTtN0eegsUW8kaiKRUduL433dIpY0tt0AFyzY1fPM4nyQXn9/aJ/PaDLtt3y0LKG1hmm7db7bd47I4bLtNf9hdAXosPq8Wa8Uqvtsti+/7/fN1VR0Oh3L9vWnrt74r131bjPPXb7vtGebgyn54rNBaqP64/fot61xtu92+7taNau2217ss/Nqv63025j+WqNp6eN121Qiv2uF1ZLsDuQO4s+XbblN8uPSjzt2oqnnYPjXmoR/aem9eQUpQZ38wj03XDPW+2Zj7Yxaj0xisPi1uv/Trl7bp9qvFbeLYruunb/vhZa2Ctn9q1i9Kp4OfviyLForVot737c0w1EeTRklcg6nR1M7UZGpvajZ1MLWYOpoarH51HhQAigCFgGJAQaAoEE3EU5MM+P343Kgf5uPz88nvyacwGoxfX5rh+MvQP2uSbq7N5LGT/4tHU4HLwtsSScAFoiDOumCyBCxE1MdHAkNSRp1BEc/6rsZ7KH0Aa8k6QIuYMRKZ0DnLnhMug9ipklhkxXlDofQ+gsNIhBTI5cWQffSUqaKQIVZRhGQUOkusElJuEB8CxyhKmTGOkdmxleDZkNO1gNVAFbtoJSlFyzYSYgAUN0JErBNWbrU9QXx0NkRSdrAUDWFJurYTa5VGEJOWDm0UJ47JomJ8yShBIJCocy4W5qiBvHJSeg2Gh+DR+RiduXJcxoC6AMTggwshi9AKiJotghwhiyB65WOn6BgDqYxKZlGkQ9IoBz+KvBfyViiSk6Tp1EeiGByGbGIWaawicWCGyPFdUazmS4OjieYRFTVabH1CeYejYWqqA0pWiHs3ImpWENQIFwFodCkmOlaPdJHRy5T2tKa65DEbq8GwmmENHWhSKXkeSmTRF9REal6ZM4wDhqA5SVG2SRRLJiKNpFrnGaM2XPVPx60W9323ORma7WZZ3EORW/G35mGH791YmH7YNIPudIX5M3XK2Fw33TERJtVTAjwnSL08j8BdENA8Ajon0I3CzyPw5wS6y/A8Aj4n0C0qzCMIFwQyj0DOCXg2QTwn0N01ziMAe86Q9++ZFHBJATMpJuWYj5CZFQ2TisxH0MyihklR5iNsZl3DpC7HI3AmB/8Lx8z2gEl15mN4ZofApEDzMT6zSWBSo+M1YOZuNalSkP8bj+pk+6z+vtzo8OLiU33cij4tKr0Orv4CPf+4+EEKAAA=]]></Template>" &_
									  "<Template format=""base64:gzip:mrv""><![CDATA[H4sIAAAAAAAAAJ2WS2+bQBDH7/kUoz3XsLPvtWxHVnOplFRt00Nv0QaTBMlACvj17TvYeRjjqqECrNXuf37MDrMznlxu8yWs06rOymLKMOIM0iIpF1nxOGWbrFiUm3qEQgt2OZskpCV9UU/ZU9M8j+N4s9lEyVOah21ZREmZs8P6eFtnHc1GRmX1GAvOMf51c327txllRd2EIknJqs7G9X7yukxCs3fmL6+I81CtsyI+yOO8Wh9od+juEO94tK0X7H1Ln2ltTqbwkC1TeCirPDSwRhchbfYTPKZFWoUmXcD9bj8tJMVgdjG5uSqTVZ4WzWxy0zKyJCxvm2qV0EReLtNkRTgafLmashzZbBKaMp9XVdhBO2qnA0IQECQEBUFDMBAsBAfBQ0BOD60jCZAUSBIkDRr6AMu0ffHP3XNK/sPr9fXl6VwMKADfV2m1+1aVz/Rh5mM4vvnbz7mbAi+mTGNkjUArUFm0TivQPFLCGcGdQGe1ENDXKB9xrxwprLTCcXvOqjfTt1KWyIhKaqG1454bUIbMrOLKWauktBqUJjNpjBHCE/BjEhlZ7b2w2iFKr9SHJIK4Bp3zUtCCcAx2FKIR7YQ8E15xSwCvPIwoJIY899yTXmttYUS7o1U6LkajoXkHZw1lJNBI7aWTHrUklXKR9uSWs0YqIc1Z1H+KznhAMefacMOlQmmk9edd72/wI2GgsxC/HYbZ5L4sFkdDyBZTdo9sf0p+pA+1eDkoDMpqkVZUhBj8bhP6kP/zYtcCW9NjgOgB5DCA7ALoGKphANUD6GEA3QVQETDDAKYLoApihwFsF2AGA1wX0Fa3YQDfBbS1cRgAeZewL60DEdhH4EDEaTq21X1gRqM8wxiY1HiSlPsOMzCv8SQv991pYGrjSWoeuttAxkl2vnbHfzPio5ITv/ZqGvb6ePze5C8mMf27mf0BZtDhyBAJAAA=]]></Template>" &_
									"</Clean2D>" &_
									"<RemoveAtomValues ID=""Remove Atom Values""/>" &_
								  "</Actions>" &_
								"</StandardizerConfiguration>"
End If

optionStr = optionStr &"!tautomerSearch:"&configTautomer
optionStr = optionStr &"!absoluteStereo:"&configAbsoluteStereo
optionStr = optionStr &"!stereoSearchType:"&configStereoSearchType
optionStr = optionStr &"!stereoModel:"&configStereoModel
optionStr = optionStr &"!ignoreTetrahedralStereo:"&configIgnoreTetrahedralStereo
optionStr = optionStr &"!ignoreDoubleBondStereo:"&configIgnoreDoubleBondStereo
optionStr = optionStr &"!ignoreAlleneStereo:"&configIgnoreAlleneStereo
optionStr = optionStr &"!ignoreAxialStereo:"&configIgnoreAxialStereo
optionStr = optionStr &"!ignoreSynAntiStereo:"&configIgnoreSynAntiStereo
optionStr = optionStr &"!exactStereoMatching:"&configExactStereoMatching
optionStr = optionStr &"!exactQueryAtomMatching:"&configExactQueryAtomMatching
%>