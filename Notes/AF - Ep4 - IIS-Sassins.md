# AF - Ep4

# Topic

IIS-Sassins

Internet Information Services (IIS) is a commonly used web server produced by Microsoft to assist organizations of all sizes to host content publicly or internally including  on premise SharePoint or Exchange. IIS modules are like building blocks, modules may be added to the server in order to provide the desired functionality for applications. It is typically not very common on static IIS instances, like Exchange or SharePoint on premise. How are modules installed? Simply by using one of three methods on Windows - The IIS interface, AppCmd.exe and PowerShell New-WebGlobalModule. How are adversaries using IIS modules? Microsoft published two blogs in 2022 ([July](https://www.microsoft.com/en-us/security/blog/2022/07/26/malicious-iis-extensions-quietly-open-persistent-backdoors-into-servers/) and [December](https://www.microsoft.com/en-us/security/blog/2022/12/12/iis-modules-the-evolution-of-web-shells-and-how-to-detect-them/)) detailing first how adversaries will persist with IIS modules and later showcasing how to detect them. In parallel, CrowdStrike has been tracking a campaign since 2021 dubbed [IceApple](https://www.crowdstrike.com/wp-content/uploads/2022/05/crowdstrike-iceapple-a-novel-internet-information-services-post-exploitation-framework-1.pdf) that has evolved over the years by installing multiple modules to perform different post-exploitation functions.

***IIS Modules***

Content

- GACUTIL (gacutil /i)
- AppCmd (%windir%\system32\inetsrv\appcmd.exe install module /name:namehere /image:pathtodll.dll)
- Pwsh Cmdlets (new-webglobalmodule)

# References

- Atomic
    - [T1505.004](https://github.com/redcanaryco/atomic-red-team/tree/master/atomics/T1505.004) -testnumbers 1
    - [T1505.004](https://github.com/redcanaryco/atomic-red-team/tree/master/atomics/T1505.004) -testnumbers 2
    - [T1562.002](https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1562.002/T1562.002.md) -testnumber 1
    - [T1562.002](https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1562.002/T1562.002.md) -testnumber 2
- Splunk Content
    - [https://research.splunk.com/stories/iis_components/](https://research.splunk.com/stories/iis_components/)
- References
    - [https://www.microsoft.com/en-us/security/blog/2022/07/26/malicious-iis-extensions-quietly-open-persistent-backdoors-into-servers/](https://www.microsoft.com/en-us/security/blog/2022/07/26/malicious-iis-extensions-quietly-open-persistent-backdoors-into-servers/)
    - [https://www.microsoft.com/en-us/security/blog/2022/12/12/iis-modules-the-evolution-of-web-shells-and-how-to-detect-them/](https://www.microsoft.com/en-us/security/blog/2022/12/12/iis-modules-the-evolution-of-web-shells-and-how-to-detect-them/)
    - [https://www.crowdstrike.com/wp-content/uploads/2022/05/crowdstrike-iceapple-a-novel-internet-information-services-post-exploitation-framework-1.pdf](https://www.crowdstrike.com/wp-content/uploads/2022/05/crowdstrike-iceapple-a-novel-internet-information-services-post-exploitation-framework-1.pdf)
    - [https://securelist.com/the-sessionmanager-iis-backdoor/106868/](https://securelist.com/the-sessionmanager-iis-backdoor/106868/)
    - [https://www.malwarebytes.com/blog/news/2022/07/iis-extensions-are-on-the-rise-as-backdoors-to-servers](https://www.malwarebytes.com/blog/news/2022/07/iis-extensions-are-on-the-rise-as-backdoors-to-servers)
- Modules to Test with
    - [https://github.com/0x09AL/IIS-Raid](https://github.com/0x09AL/IIS-Raid)
    - 

# Infrastructure needed

- IIS

# Mitigations

- Patch web apps
- Move web servers into a DMZ and restrict internal access.
- Disable egress to only what is needed by servers
- Use application control to dismiss any new binaries on disk
- Use a web application firewall
- Move left: prevent the activity first.
- Inventory Modules

## Enable Logging

In the Microsoft [blog](https://www.microsoft.com/en-us/security/blog/2022/12/12/iis-modules-the-evolution-of-web-shells-and-how-to-detect-them/) it is recommended to enable advanced IIS logging to hunt for web shells. The Microsoft-IIS-Configuration/Operational log provides details on new modules being added by site/app pool.

- Lists additional logs available for IIS: `wevtutil el | findstr -i IIS`
- Configuration for the selected log: `wevtutil gl Microsoft-IIS-Configuration/Operational`
- Enable the selected log: `wevtutil sl /e:true Microsoft-IIS-Configuration/Operational`

[https://lh6.googleusercontent.com/BeIML2CLTCfe2-PiMS41lQJ5Fo95xd7Z2KqiwcGWjQ6XcRSXrdhfE5amWfq3o-SpiUbL_MWWns-IV5jN3lhwJwqxOo7-nsxhkykXPFda5t_S0P5yXuBx6isCmEYhFe51JZOf-AWcce2W17Dzj_cd4ouoT_6r0zoWrXnmhIYBKbtgZfAnaS-h7IGmxefDQQ](https://lh6.googleusercontent.com/BeIML2CLTCfe2-PiMS41lQJ5Fo95xd7Z2KqiwcGWjQ6XcRSXrdhfE5amWfq3o-SpiUbL_MWWns-IV5jN3lhwJwqxOo7-nsxhkykXPFda5t_S0P5yXuBx6isCmEYhFe51JZOf-AWcce2W17Dzj_cd4ouoT_6r0zoWrXnmhIYBKbtgZfAnaS-h7IGmxefDQQ)

### Inputs.conf

```
[WinEventLog://Microsoft-IIS-Configuration/Operational]
index=win
sourcetype=IIS:Configuration:Operational
disabled = false
###
# Modify cron schedule as you like. Default is once daily.
# Modify index as needed.
# We recommend this method over the other options provided.
###
[powershell://IISModules]
script = Get-WebGlobalModule
schedule = */1 * * * *
#schedule = 0 0 * * *
sourcetype = Pwsh:InstalledIISModules
index=iis
```

[https://gist.github.com/MHaggis/64396dfd9fc3734e1d1901a8f2f07040](https://gist.github.com/MHaggis/64396dfd9fc3734e1d1901a8f2f07040)

Once logged, in Splunk it looks like this:

[https://lh6.googleusercontent.com/y8XG7QN8caZAxYPp9e1uN83j_bZ03pDZL37KuP5Sls6Ki9Z65ynrR-rftEnqx6-T6gX2TjkYtf04oNSgrPtu3nK_C8NSYKNRXXetcoB8K1EAaCLlwqnV5iTiI7ixBotr3M-Y5OmavkS-b0Bwn7EjUq9fkf-84avzM34zGu7PEIlD5nqt-e-i6mYLp1PBWQ](https://lh6.googleusercontent.com/y8XG7QN8caZAxYPp9e1uN83j_bZ03pDZL37KuP5Sls6Ki9Z65ynrR-rftEnqx6-T6gX2TjkYtf04oNSgrPtu3nK_C8NSYKNRXXetcoB8K1EAaCLlwqnV5iTiI7ixBotr3M-Y5OmavkS-b0Bwn7EjUq9fkf-84avzM34zGu7PEIlD5nqt-e-i6mYLp1PBWQ)

First is a [native](https://learn.microsoft.com/en-gb/iis/develop/runtime-extensibility/develop-a-native-cc-module-for-iis) module. A native module is typically going to be a DLL deployed to the server and loaded up via IIS Administration Tool, PowerShell or AppCmd. Per [Microsoft](https://learn.microsoft.com/en-us/iis/get-started/introduction-to-iis/iis-modules-overview#to-install-a-native-module), all three of these installation methods result in the module entry being added to the <globalModules> IIS configuration section in %windir%\system32\inetsrv\config\applicationhost.config

managed modules. Per [Microsoft](https://learn.microsoft.com/en-us/iis/get-started/introduction-to-iis/iis-modules-overview#enabling-a-module-for-an-application), a managed module do not require installation, and can be enabled directly for each application. This allows applications to include their managed modules directly within the application by registering them in the application's web.config file. %windir%\system32\inetsrv\config\applicationhost.config, and searching for the string "<modules>".

**IIS Manager**

The IIS Manager application allows for easy adding and removing of both Managed and Native modules.

[https://lh5.googleusercontent.com/OnP9j2lMcJsbQJa0_gOfAZeilIz5G9oSGGIAN9c0Hd3EnCPfBNtb_F9UXpCYl062g2ax14aZldPG6wrJ7-yJ4ShawisaAKtpeLxCoKURU2D1dMp9KAknGOwSLMTtazwp_qoPhktE7xQCpuyz1cR_ZdACJ_n_-VoRUpbYEdqVByg6aaq5b3tvU8SOEl3BUA](https://lh5.googleusercontent.com/OnP9j2lMcJsbQJa0_gOfAZeilIz5G9oSGGIAN9c0Hd3EnCPfBNtb_F9UXpCYl062g2ax14aZldPG6wrJ7-yJ4ShawisaAKtpeLxCoKURU2D1dMp9KAknGOwSLMTtazwp_qoPhktE7xQCpuyz1cR_ZdACJ_n_-VoRUpbYEdqVByg6aaq5b3tvU8SOEl3BUA)

**AppCmd.exe**

AppCmd by default is found in %windir%\system32\inetsrv\. AppCmd.exe provides all sorts of functionality to manage IIS, but for this blog we will focus on listing, adding and removing modules.

To list modules:

%windir%\system32\inetsrv\appcmd.exe list modules

[https://lh4.googleusercontent.com/3M9RUFi2j89jPFKqK9TJ2uxmz7ILfaAQYPCOpPZ5eQ33iWcOrWmn9pGJ38kt_H06EpvyGhDyu5fUq_xMNzH9tRJI_Ohg6fBCBilh6b-g4xoD5topSseQDVeJPaEa6m8lnh5JZ7EL87G322ZIfTddFe99v2oepcLBmACiMhpgxvWbcTZWYs3ySG3Cwp4zFw](https://lh4.googleusercontent.com/3M9RUFi2j89jPFKqK9TJ2uxmz7ILfaAQYPCOpPZ5eQ33iWcOrWmn9pGJ38kt_H06EpvyGhDyu5fUq_xMNzH9tRJI_Ohg6fBCBilh6b-g4xoD5topSseQDVeJPaEa6m8lnh5JZ7EL87G322ZIfTddFe99v2oepcLBmACiMhpgxvWbcTZWYs3ySG3Cwp4zFw)

Add a module

%windir%\system32\inetsrv\appcmd.exe install module /name:DefaultDocumentModule_round2 /image:%windir%\system32\inetsrv\defdoc.dll

[https://lh3.googleusercontent.com/d174ib2aTD_MNRe_Vd4idobgsIPGm-MJ8tsYdPeVpAKoE85h88RebgbtyHx_1JsoyeV5Xfbat5EdIub1943W3CGv3sFBVYLLEIb8Dm-jiYNTSrenuy7lGocamFnbV1xDLOT2k3__jB4BzMkr-aAYQwL18E_FAGzaNCexbDReMlTSM_QuBC6tcdZzzmFjbQ](https://lh3.googleusercontent.com/d174ib2aTD_MNRe_Vd4idobgsIPGm-MJ8tsYdPeVpAKoE85h88RebgbtyHx_1JsoyeV5Xfbat5EdIub1943W3CGv3sFBVYLLEIb8Dm-jiYNTSrenuy7lGocamFnbV1xDLOT2k3__jB4BzMkr-aAYQwL18E_FAGzaNCexbDReMlTSM_QuBC6tcdZzzmFjbQ)

Uninstall a module

%windir%\system32\inetsrv\appcmd.exe uninstall module DefaultDocumentModule

[https://lh5.googleusercontent.com/9qY61I2CZMuVoDHh4dC_pRZgMrjXQds6aljUo-Zj0w404wnL1jFUw_J9OuifDP_Yh6zqp6gPWpLwAtevkyX7jBEQAfN96ObHKiINQYst_BCyfZyztmMLwanICm3p1TJNuulcn-n76q6st8OiJYj8FYz5H8qyGSdnezoIkHEeWquBQLz9CC0WGyXxCizjTg](https://lh5.googleusercontent.com/9qY61I2CZMuVoDHh4dC_pRZgMrjXQds6aljUo-Zj0w404wnL1jFUw_J9OuifDP_Yh6zqp6gPWpLwAtevkyX7jBEQAfN96ObHKiINQYst_BCyfZyztmMLwanICm3p1TJNuulcn-n76q6st8OiJYj8FYz5H8qyGSdnezoIkHEeWquBQLz9CC0WGyXxCizjTg)

**PowerShell**

Similar to AppCmd, PowerShell has [cmdlets](https://learn.microsoft.com/en-us/powershell/module/webadministration/set-webglobalmodule?view=windowsserver2022-ps) we may use to do similar functions.

List modules

Get-WebGlobalModule

[https://lh3.googleusercontent.com/ZTDjZZOjJlNd4oUnyTab3b96gRK_SkQ8IcAYOW4hc-o09ng9zwbP9KRI6nf6O-UuDdmkMJZNCf6uuqsEzxzl_oZxhCcIOqsmhCRSmPTweL1sS7pyFJGhl_CtUADblB56be93RMbe92pbUY5z5N9-L5donS6CsosaH3Y92Yd55fwRLUCBr3UN0vFBe7hG2g](https://lh3.googleusercontent.com/ZTDjZZOjJlNd4oUnyTab3b96gRK_SkQ8IcAYOW4hc-o09ng9zwbP9KRI6nf6O-UuDdmkMJZNCf6uuqsEzxzl_oZxhCcIOqsmhCRSmPTweL1sS7pyFJGhl_CtUADblB56be93RMbe92pbUY5z5N9-L5donS6CsosaH3Y92Yd55fwRLUCBr3UN0vFBe7hG2g)

Add new module

New-WebGlobalModule -Name DefaultDocumentModule_Atomic2 -Image %windir%\system32\inetsrv\defdoc.dll

[https://lh3.googleusercontent.com/U_Zfj7RektSnkJEq-yqzu8IEfrTYZq7fJpQ0aIKKKjhxgP-ZEvydGrLq8F1b6ngnAJ24IJDW69XsO4TF_IowhUzlNGY8kb2VkdpStq75jg4qBCDGvF-Cz-P6JDrOIRmLlL0Hy-q8PePVbzFSvCJMo4aK9dluuJe40ltLRpNUDL9CWTL9B9bsJ7WYAvkCgg](https://lh3.googleusercontent.com/U_Zfj7RektSnkJEq-yqzu8IEfrTYZq7fJpQ0aIKKKjhxgP-ZEvydGrLq8F1b6ngnAJ24IJDW69XsO4TF_IowhUzlNGY8kb2VkdpStq75jg4qBCDGvF-Cz-P6JDrOIRmLlL0Hy-q8PePVbzFSvCJMo4aK9dluuJe40ltLRpNUDL9CWTL9B9bsJ7WYAvkCgg)

Uninstall module

Remove-WebGlobalModule -Name DefaultDocumentModule_Atomic2

[https://lh3.googleusercontent.com/TBkEKGNmxguBOcq5KcUEiYSMCAw-u0k359txMdsoQJPIA4xsIrXqAu2UxRrZHLYW4ZutIzxHWHWCKaUBi3X0m1nGjgVpGOkGt9o-MdnRew9xRN0ZEOVvOLgWfxOqZkjjgmbovyZr-J_2LUnHxf6TWDpEVSy9EJq-xv59MjRXhyQjee5Efb_8fwgPNc4a8A](https://lh3.googleusercontent.com/TBkEKGNmxguBOcq5KcUEiYSMCAw-u0k359txMdsoQJPIA4xsIrXqAu2UxRrZHLYW4ZutIzxHWHWCKaUBi3X0m1nGjgVpGOkGt9o-MdnRew9xRN0ZEOVvOLgWfxOqZkjjgmbovyZr-J_2LUnHxf6TWDpEVSy9EJq-xv59MjRXhyQjee5Efb_8fwgPNc4a8A)