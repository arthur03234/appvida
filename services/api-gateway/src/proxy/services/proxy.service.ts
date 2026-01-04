import { Injectable, HttpException, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { AxiosRequestConfig, AxiosError } from 'axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class ProxyService {
  private readonly logger = new Logger(ProxyService.name);

  constructor(private readonly httpService: HttpService) {}

  async forwardRequest(
    serviceUrl: string,
    path: string,
    method: string,
    data?: any,
    headers?: any,
  ) {
    const url = `${serviceUrl}${path}`;
    
    const config: AxiosRequestConfig = {
      method,
      url,
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
    };

    if (data) {
      config.data = data;
    }

    this.logger.log(`Forwarding ${method} request to: ${url}`);

    try {
      const response = await firstValueFrom(
        this.httpService.request(config),
      );
      return response.data;
    } catch (error) {
      this.handleError(error as AxiosError);
    }
  }

  private handleError(error: AxiosError) {
    this.logger.error(`Proxy error: ${error.message}`);
    
    if (error.response) {
      throw new HttpException(
        error.response.data || 'Service error',
        error.response.status,
      );
    }
    
    throw new HttpException(
      'Service unavailable',
      503,
    );
  }
}
