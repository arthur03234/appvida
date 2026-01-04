import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { AuthProxyController } from './controllers/auth-proxy.controller';
import { UserProxyController } from './controllers/user-proxy.controller';
import { ProxyService } from './services/proxy.service';

@Module({
  imports: [HttpModule],
  controllers: [AuthProxyController, UserProxyController],
  providers: [ProxyService],
})
export class ProxyModule {}
